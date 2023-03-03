#!/bin/bash
#Перед выполнением скрипта необходимо
#Прокинуть ssh ключь сервера мониторинга на сервера кластера и бэка 
#Ip адресса серверов с psql а так же back
ippatroni1=''
ippatroni2=''
ipback=''
##Переменные с определением токена и id от Telegram
token=''
id=''



# Скрипт написан на условии проверки кода ответа от команд
#1 Скрипт выполняет команду которая запрашивает у API patroni статус состояния кластера. Вывод фильтруется на наличее строк grep '"role": "master"'
#2 Далее проверяет условие.  Если код ответа команды =1. Значит команда выполнилась не успешно и patroni 1 не является master
#  В этом случае записывает в переменную список кто является мастером, а кто слайвом
#3 И присылает сообщение в телеграм PATRONI-1 FAILD где перекрепленн список
#4 Далее в /etc/crontab заменяет status-patroni1.sh на status-patroni2.sh. Теперь Крон будет запускать скрипт status-patroni2.sh вместо этого
#5 Перезапускает бэк  
#6 Далее проверяет условие.  Если код ответа команды =1. Значит команда выполнилась не успешно и бэк не перезапущен
#  В этом случае скрипт присылает сообщение в телеграмм  Не получилось перезапустить бэк  
#7 Если код ответа 0 то значит бэк перезапущен и выполняется команда по остановке шлюза №1
#8 Далее проверяет условие.  Если код ответа команды =1. Значит команда выполнилась не успешно и скрипт не смог остановить шлюз
#  В этом случае скрипт присылает сообщение в телеграмм Не остановлен шлюз 1
#9 Если код ответа 0 то просто выводится Шлюз 1 остановлен
#10 Выполняет команда по запуску шлюза №2
#11 Далее проверяет условие.  Если код ответа команды =1. Значит команда выполнилась не успешно и скрипт не смог запустить шлюз
#   В этом случае скрипт присылает сообщение в телеграмм Не запустился шлюз 2
#12 Если код ответа 0 то скрипт выводит Шлюз 2 запущен
#13 Выводит сообщение Бэк перезапущен (Заключительная часть условия. Когда код ответа 0 команды по перезапуску бэка)
#14 Если код ответа 0 то просто выводит ОК. (Заключительная часть проверки кода ответа команды проверки статуса состояния кластера)


if 
#1
   curl -s http://$ippatroni1:8008/patroni | jq . | grep '"role": "master"' 
   [ "$?" -eq 1 ] 
then 
#2  
   l=`ssh root@$ippatroni1 "patronictl -c /etc/patroni.yml list" | tail -3 | head -2` 
#3
   curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="PATRONI-1 FAILD 
$l" > /dev/null
#4
   sed -r 's|script-status-patroni/status-patroni1.sh.|script-status-patroni/status-patroni2.sh |' /etc/crontab -i
      if 
#5     
         ssh root@$ipback "docker restart api-qa"
         [ "$?" -eq 1 ] 
      then
#6   
         curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="Не получилось перезапустить бэк" > /dev/null
      elif
         [ "$?" -eq 0 ]
            if 
#7
               ssh root@$ippatroni1 "systemctl stop live.service && systemctl stop prematch.service"
               [ "$?" -eq 1 ]
            then 
#8
               curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="Не остановлен шлюз 1" > /dev/null
            elif
               [ "$?" -eq 0 ]
            then
#9
               echo "Шлюз 1 остановлен"
            fi
            if 
#10
               ssh root@$ippatroni2 "systemctl start live.service && systemctl start prematch.service"
              [ "$?" -eq 1 ]
            then 
#11
               curl -s -X POST https://api.telegram.org/bot$token/sendMessage -d chat_id=$id -d text="Не запустился шлюз 2" > /dev/null
            elif
               [ "$?" -eq 0 ]
            then
#12
               echo "Шлюз 2 запущен"
            fi   
      then
#13
         echo "Бэк перезапущен"
      fi
elif
   [ "$?" -eq 0 ]
then
#14
   echo "Ok"
fi
