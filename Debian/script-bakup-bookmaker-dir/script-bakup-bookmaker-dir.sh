#!/bin/bash
##Формат даты
fdate=`date +%Y-%m-%d`
###IP 
ipprodapp=''
ipbkp2=''
#####Директории 
dirdump=/backup/bookmaker-dir
log=/var/log/script/script-bakup-bookmaker-dir/log-script-bakup-bookmaker-dir
######Переменные с определением токена и id от Telegram
token=''
id=''

#1 Скрипт копирует директорию /bookmaker/ на сервере bk-prod-app и архивирует её
#2 Cкрипт отправляет архив на серевер bkp-2 
#3 Далее проверяет код ответа команды. 
#  Если код ответа команды =1. Значит команда выполнилась не успешно и скрипт не смог отправить бэкап на сервер bkp-2
#  В этом случае скрипт присылает сообщение в телеграмм Бэкап директории bookmaker не снят
#4 Если код ответа команды =0. Значит команда выполнилась успешно
#  В этом случая скрипт записывает в лог файл строку  Бэкап директории bookmaker снят
#5 И удаляет с сервера bk-prod-app скопированную дирекорию и архив
#6 Скрипт удалит бэкапы старше 7 дней на сервере bkp-2

set -euo pipefail
#1
ssh root@$ipprodapp "cp -R /srv/bookmaker/ /srv/bakup-bookmaker-dir/ && \
gzip -c9 -r /srv/bakup-bookmaker-dir/bookmaker > /srv/bakup-bookmaker-dir/bookmaker_$fdate.gz" && echo "Директория скопирована и заархивированна"

if 
#2
    ssh root@$ipprodapp "scp /srv/bakup-bookmaker-dir/bookmaker_$fdate.gz root@$ipbkp2:$dirdump"
    [ "$?" -eq 1 ]
then
#3
    curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="$fdate Бэкап директории bookmaker не снят" > /dev/null
    echo "Бэкап директории bookmaker не снят"
elif
    [ "$?" -eq 0 ]
#4
    echo "Бэкап директории bookmaker снят" && echo "$(date) Бэкап директории bookmaker снят" >> $log
then
#5
    ssh root@$ipprodapp "rm -r /srv/bakup-bookmaker-dir/bookmaker && rm /srv/bakup-bookmaker-dir/bookmaker_$fdate.gz"
    echo "На back все почищенно"
fi
#6
ssh root@$ipbkp2 "find $dirdump -type f -mtime +7 -delete"