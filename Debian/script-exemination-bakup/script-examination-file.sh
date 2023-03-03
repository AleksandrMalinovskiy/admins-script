#!/bin/bash
#Формат даты
fdate=`date +%Y-%m-%d`
extime=$(date +%H)
dumpdate=$(date +%d.%m.%y)
buckpdate=$(date +%d.%m.%y-%H:%M)
##Директории 
log=/var/log/script/script-examination-dump/log-script-examination-dump-$fdate
dirdump=/mnt/backup/examination/
###IP 
ipbkp1=''
####Переменные с определением токена и id от Telegram
token=''
id=''

##Скрипт написан на проврке условия
#1 Скрипт проверяет наличие дампа за последний час на сервере bkp-1
#2 Далее проверяет условие.  Если код ответа команды =1. Значит бэкапа нет.
#  В этом случае скрипт присылает сообщение в телеграмм  Сервер bkp-1. Отсутствует бэкап БД за последний час. Запущен скрипт для снятия бэкапа
#  Так же запускает скрипт проверки и снятия бэкапа
#3 Если код ответа 0 то значит бэкап за последний час присутствует. 
#  В этом случает скрипт запишит в логи сообщение  Север bkp-1. Бэкап БД за последний час времени присутсвует

if 
#1
    ssh root@$ipbkp1 "ls $dirdump | grep 'bkgwdb_$dumpdate-$extime:*'"
    [ "$?" -eq 1 ]
then 
#2
    curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="$buckpdate Сервер bkp-1. Отсутствует бэкап БД за последний час. Запущен скрипт для снятия бэкапа" > /dev/null
    bash /home/script/script-exemination-bakup/script-history.sh
elif
    [ "$?" -eq 1 ]
then
#3
    echo "$buckpdate. Север bkp-1. Бэкап БД за последний час времени присутсвует" >> $log
fi