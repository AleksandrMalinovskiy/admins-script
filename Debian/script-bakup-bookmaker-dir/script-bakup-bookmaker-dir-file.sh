#!/bin/bash
#Формат даты
fdate=`date +%Y-%m-%d`
extime=$(date +%H)
dumpdate=$(date +%d.%m.%y)
buckpdate=$(date +%d.%m.%y-%H:%M)
##Директории 
log=/var/log/script/script-bakup-bookmaker-dir/log-script-bakup-bookmaker-dir
dirdump=/backup/bookmaker-dir
###IP 
ipbkp2=''
####Переменные с определением токена и id от Telegram
token=''
id='890399189'

##Скрипт написан на проврке условия
#1 Скрипт проверяет наличие бэкапа директории /bookmaker/ на сервере bkp-2
#2 Далее проверяет условие.  Если код ответа команды =1. Значит бэкапа нет.
#  В этом случае скрипт присылает сообщение в телеграмм  Сервер bkp-2. Отсутствует бэкап директории /bookmaker/. Запущен скрипт для снятия бэкапа
#  Так же запускает скрипт снятия бэкапа
#3 Если код ответа 0 то значит бэкап за последний час присутствует. 
#  В этом случает скрипт запишит в логи сообщение  Север bkp-2. Бэкап директории bookmaker/ присутствует

if 
#1
    ssh root@$ipbkp2 "ls $dirdump | grep '$fdate'"
    [ "$?" -eq 1 ]
then 
#2
    curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="$fdate Сервер bkp-2. Отсутствует бэкап директории /bookmaker/. Запущен скрипт для снятия бэкапа" > /dev/null
    bash /home/script/script-bakup-bookmaker-dir/script-bakup-bookmaker-dir.sh
elif
    [ "$?" -eq 1 ]
then
#3
    echo "$fdate. Север bkp-2. Бэкап директории bookmaker/ присутствует" >> $log
fi