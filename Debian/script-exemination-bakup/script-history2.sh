#!/bin/bash
#Формат даты
fdate=`date +%Y-%m-%d`
#Директория для лога скрипта 
logdir=/var/log/script/script-examination-dump/script-history/log-script-history_$fdate
#Скрипт написан для дебага скрипта проверки дампа (script-examination-dump2.sh)
#Он запишет всю историю скрипта по которой можно будет отслеоить где происходят ошибки в скрипте
echo "=============== SCRIPT EXAMINATION DUMP 2 ========================" >> $logdir && echo "$(date)" >> $logdir && bash /home/script/script-exemination-bakup/script-examination-dump2.sh >> $logdir