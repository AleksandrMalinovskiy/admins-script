#!/bin/bash
##Формат даты
fdate=`date +%Y-%m-%d`
extime=$(date +%H)
buckpdate=$(date +%d.%m.%y-%H:%M)
###IP 
ipprodgw=''
ipbkp1=''
####Данные от ДБ
pgpasswd=''
#####Директории 
dirdump=/mnt/backup/examination
log=/var/log/script/script-examination-dump/log-script-examination-dump-$fdate
errlog=/var/log/script/script-examination-dump/errorlog-script-examination-dump/errorlog-script-examination-dump-$fdate
histlog=/var/log/script/script-examination-dump/script-history/dump-log/log-dump_$buckpdate
######Переменные с определением токена и id от Telegram
token=''
id=''

set -euo pipefail

#1 Скрипт развернет постгрес в dockere на сервере bkp-1
#2 Снимет дамп с прода и сохранить его на сервере bkp-1
#3 Развернет снятый дамп на сервере bkp-1. Всю историю разворота запишел в файл log-dump
#4 Проверка файла log-dump на наличие ошибок при развороте бэкапа 
#5 Далее проверяет условие.  Если код ответа команды =1. Значит при развороте бэкапа были ошибки. 
#  В этом случае скрипт присылает сообщение в телеграмм Найдены ошибки при развороте бэкапа сервер bkp-1. 
#  Так же удалит снятый дамп и постгрес вместе с БД
#6 Если код ответа 0 значит что дамп развернулся успешно. Скрипт удалит файл log-dump и начнет проверку
#7 Начало проверки
#  В переменную list скрипт записывает содержание столбца created_at таблицы odds 
#8 Выводит содержание переменной list и через grep фильтруем его по 2 критериям - это дата выполнения скрипта и час выполнения скрипта
#  Например: дата и время выполнения скрипта 01.01.23 в 01:10. 
#  По итогу он должен найти записи на дату 01.01.23 и промежуток времени от 01:00 до 01:10. 
#9 Далее проверяет условие.  Если код ответа команды =1. Значит не найдено записи удолетворяющие критерию и проверка не пройдена.
#  В этом случае скрипт присылает сообщение в телеграмм Проверка не пройдена бэкап (дата час) сервер bkp-1
#  Так же в логи записывает последние 15 записей из столбца created_at таблицы odds. По этому логу можно провести дебак или опсследование. 
#  Удаляется постгрес вместе с БД и дампом
#10 Если код ответа 0 значит что проверка прошла успешно. Дамп архивируется и сохраняется. Постгрес удаляется вместе с БД. Удаляется временный файл.
#11 Запись в логи скрипта 
#12 Удалить скрипты старше 3х дней

#1
ssh root@$ipbkp1 "docker-compose -f /srv/postgres/docker-compose.yml up -d " && echo "Постгрес поднят"
#2
pg_dump -h $ipprodgw -p 5433 -U bkgwuser -d bkgwdb | ssh root@$ipbkp1 "cat > $dirdump/bkgwdb" && echo "ДАМП СНЯТ"
#3
ssh root@$ipbkp1 "PGPASSWORD=$pgpasswd psql -h localhost -p 5432 -U bkgwuser -d test < $dirdump/bkgwdb" >> $histlog && echo "ДАМП РАЗВЕРНУТ"

if
#4
    cat $histlog | grep "ERROR" 
    [ "$?" -eq 0 ]
#5
then 
    curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="Найдены ошибки при развороте бэкапа $buckpdate сервер bkp-1" > /dev/null
    ssh root@$ipbkp1 "rm $dirdump/bkgwdb &&\
    docker stop db-examination-dump-prod && \
    docker rm db-examination-dump-prod && \
    rm -r /srv/postgres/pg-data/" && echo "Найдены ошибки при развороте бэкапа $buckpdate сервер bkp-1."
elif
    [ "$?" -eq 1 ]
#6
    echo "Ошибок при развороте бэкапа не найдено"
    rm $histlog
#7
    list=$(ssh root@$ipbkp1 "PGPASSWORD=$pgpasswd psql -h localhost -p 5432 -U bkgwuser -d test -c 'SELECT created_at FROM odds;'") > /dev/null && echo "Запрос в БД"

    if 
#8
        echo "$list" | egrep "$fdate $extime" | sort | tail -15 && echo "Проверка начата" 
        [ "$?" -eq 1 ]
    then 
#9
        curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="Проверка не пройдена бэкап $buckpdate сервер bkp-1" > /dev/null
        echo "Проверка не пройдена бэкап $buckpdate сервер bkp-1"
        list=$(ssh root@$ipbkp1 "PGPASSWORD=$pgpasswd psql -h localhost -p 5432 -U bkgwuser -d test -c 'SELECT created_at FROM odds;'") > /dev/null
        echo "$list" | grep "$fdate" | sort | tail -15 >> $errlog
        ssh root@$ipbkp1 "docker stop db-examination-dump-prod && \
        docker rm db-examination-dump-prod && \
        rm -r /srv/postgres/pg-data/ && \
        rm $dirdump/bkgwdb" && echo "Постгрес удален вместе с БД и дампом"
    elif
        [ "$?" -eq 0 ]
#10
        echo "Проверка дампа произведена"
        ssh root@$ipbkp1  "gzip -c9 $dirdump/bkgwdb > $dirdump/bkgwdb_$buckpdate.gz" && echo "Заархивированно"
        ssh root@$ipbkp1 "docker stop db-examination-dump-prod && \
        docker rm db-examination-dump-prod && \
        rm -r /srv/postgres/pg-data/" && echo "Постгрес удален вместе с БД"
        ssh root@$ipbkp1 "rm $dirdump/bkgwdb"
    then
        echo "OK" > /dev/null

    fi
#11
then
    echo "$buckpdate. Сервер bkp-1. Бэкап bkgwdb_$buckpdate проверен и сохранен." >> $log
fi
#12 
ssh root@$ipbkp1 "find $dirdump -mtime +2 -exec rm {} +"




 

