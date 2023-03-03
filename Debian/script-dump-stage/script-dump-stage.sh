######ЭТО СТАРАЯ ВЕРСИЯ СКРИПТА НЕОБХОДИМО ПОДОГНАТЬ ЕГО ПО АРХЕТЕКТУРУ
#!/bin/bash
fdate=`date +%Y-%m-%d`
database=stage_db
ipprod=''
ipsatgeback=''
ipstagegw=''
ipstageparser=''

#Остановить бэк
ssh root@$ipsatgeback "docker stop admins-api" && echo "BACK ОСТАНОВЛЕН" && echo "$fdate BACK ОСТАНОВЛЕН" >> /home/dump-prod/journal.txt

#Остановить парсер
ssh root@$ipstageparser "docker stop stage.line"
ssh root@$ipstageparser "docker stop stage.live"

#Остановить шлюз 
systemctl stop live.service &&  systemctl stop prematch.service && echo "ШЛЮЗ ОСТАНОВЛЕН" && echo "$fdate ШЛЮЗ ОСТАНОВЛЕН" >> /home/dump-prod/journal.txt

#Удалить БД 
psql -h localhost -U postgres --command="DROP DATABASE $database;" && echo "БД УДАЛЕНА" && echo "$fdate БД УДАЛЕНА" >> /home/dump-prod/journal.txt

#Создать БД 
psql -U postgres -h localhost --command="create database $database;" && echo "БД СОЗДАНА" && echo "$fdate БД СОЗДАНА" >> /home/dump-prod/journal.txt

#Дать права на БД юзеру 
psql -h localhost -U postgres --command="GRANT ALL PRIVILEGES ON DATABASE "$database" to bkgwuser;"
psql -h localhost -U postgres -d $database --command="GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "bkgwuser";" && echo "НА БД ДАННЫ ПРАВА" && echo "$fdate НА БД ДАННЫ ПРАВА" >> /home/dump-prod/journal.txt

#Снять дамп БД
#touch /root/.pgpass && 0600 /root/.pgpass
#сервер:порт:база_данных:имя_пользователя:пароль

pg_dump -h $ipprod -p 5433 -U bkgwuser -d bkgwdb > /home/dump-prod/dump$fdate  && echo "ДАМП СНЯТ" && echo "$fdate ДАМП СНЯТ" >> /home/dump-prod/journal.txt

#Влить дамп
psql -h $ipstagegw -p 5432 -U bkgwuser -d $database < /home/dump-prod/dump$fdate && echo "ДАМП ВЛИТ" && echo "$fdate ДАМП ВЛИТ" >> /home/dump-prod/journal.txt

#Запустить бэк 

ssh root@$ipsatgeback "docker start admins-api" && echo "БЭК ЗАПУЩЕН" && echo "$fdate БЭК ЗАПУЩЕН" >> /home/dump-prod/journal.txt

#Запустить шлюз 
systemctl start live.service && systemctl start prematch.service && echo "ШЛЮЗ ЗАПУЩЕН" && echo "$fdate ШЛЮЗ ЗАПУЩЕН" >> /home/dump-prod/journal.txt

#Запустить парссер
ssh root@$ipstageparser "docker start stage.line"
ssh root@$ipstageparser "docker start stage.live"

#Удалить старый дамп 
#find /home/dump-prod/ -type f -mtime +1 -delete
