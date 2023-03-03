#!/bin/bash
#IP адресса 
ipkeitaro=''
serverbkp2=''
##Переменные формата даты и переменная для опредиления места логов скрипта 
fdate=`date +%Y-%m-%d`
logdat=$(date '+%d-%m-%y %H:%M')
log=/var/log/script/script-backup-keitaro/log-script-backup-keitaro
###Переменные с определением токена и id от Telegram
token=''
id=''


# Скрипт написан на условии проверки кода ответа от команд
#1 Выполняет команду по снятию дампа
#2 Далее проверяет условие.  Если код ответа команды =1. Значит команда выполнилась не успешно и скрипт не смог снять дамп. 
#  В этом случае присылает сообщение в телеграмм Неудалось снять дамп keitaro
#3 Если код ответа 0 то значит дам снялся успешно. При этом условии скрипт его архивирует и размещает в  /srv/dumpkeitaro/
#4 Далее проверяет условие.  Если код ответа команды =1. Значит команда выполнилась не успешно и скрипт не смог заархивировать дамп.
#  В этом случае он присылает сообщение в телеграмм Неудалось заархивировать дамп keitaro
#5 Если код ответа 0 то значит дамп заархивированн. После он отправляет его на сервер bkp-2
#6 Далее проверяем условие.  Если код ответа команды =1. Значит команда выполнилась не успешно и скрипт не смог отправить дамп на сервер bkp-2.
#  В этом случае он присылает сообщение в телеграмм Неудалось отправить дамп keitaro на сервер bkp-2
#7 Если код ответа 0 то значит что скрипт успешно отправил дамп на сервер bkp-2
#  В этом случае записывает сообщение в лог файл Дамп снят заархивирован и отправлен
#8 Команда которая удалит дам старше 35 дней на сервере кейтаро
#  Таким образом на сервере кейтаро всегда будет два последних дампа 
#9 Команда которая удалит дам старше 95 дней на сервере bkp-2
#  Таким образом на сервере bkp-2 всегда будет шесть последних дампов 

if 
# 1   
    ssh root@$ipkeitaro "kctl transfers dump"
    [ "$?" -eq 1 ]
then 
#2
    curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="Неудалось снять дамп keitaro" > /dev/null
elif
    [ "$?" -eq 0 ]
    if
#3
        ssh root@$ipkeitaro "gzip -c9 -r /var/lib/kctl-transfers/ > /srv/dumpkeitaro/keitarodump$fdate.gz"
        [ "$?" -eq 1 ]
    then
#4
        curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="Неудалось заархивировать дамп keitaro" > /dev/null
    elif
        [ "$?" -eq 0 ]
        if 
#5
            ssh root@$ipkeitaro "scp /srv/dumpkeitaro/keitarodump$fdate.gz root@$serverbkp2:/backup/keitaro/" && echo "$(date) Дамп снят заархивирован и отправлен" >> $log
            [ "$?" -eq 1 ]
        then
#6
            curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="Неудалось отправить дамп keitaro на сервер bkp-2" > /dev/null
        elif
            [ "$?" -eq 0 ]
        then
#7
            echo "Дамп снят заархивирован и отправлен" && echo "$(date) Дамп снят заархивирован и отправлен" >> $log
        fi
    then
        echo "Ок"
    fi
then
    echo "Ок"
fi
#8
ssh root@$ipkeitaro "find /srv/dumpkeitaro/ -type f -mtime +35 -delete"
#9
ssh root@$serverbkp2 "find /backup/keitaro/ -type f -mtime +95 -delete"

