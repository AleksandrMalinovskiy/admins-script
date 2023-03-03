[Директория: script-bakup-bookmaker-dir ](/script-bakup-bookmaker-dir/)

[Скрипт: script-bakup-bookmaker-dir-file.sh](/script-bakup-bookmaker-dir/script-bakup-bookmaker-dir-file.sh)

    Описание: Проверка наличие бэкапа за сутки 

    Время выполнения: В 00:30 каждый день

[Скрипт: script-bakup-bookmaker-dir.sh](/script-bakup-bookmaker-dir/script-bakup-bookmaker-dir.sh)

    Описание: Скрипт снятия бэкапа директории bookmaker/

    Время выполнения: В 00:00 каждый день
____
[Директория: script-clear/](/script-clear/)

[Скрипт: clear.sh](/script-clear/clear.sh)

    Описание: Очистка места на серверах указанных в list

    Время выполнения: В 00:00 каждое воскресенье
______
[Директория: script-dump-stage/](/script-dump-stage/)

[Скрипт: script-dump-stage.sh](/script-dump-stage/script-dump-stage.sh)

    Описание: Снятие дампа с прода и разворот его на stage

    Время выполнения: Кроном не выполняется. Запуск руками
_______
[Директория: script-exemination-bakup/](/script-exemination-bakup/)

[Скрипт:  script-examination-dump.sh](/script-exemination-bakup/script-examination-dump.sh)

    Описание: Снятие дампа с прода и проверка его. При положительной проверке сохраняет его на сервер bkp-1

    Время выполнения: Запускается скриптом script-history.sh

[Скрипт: script-history.sh](/script-exemination-bakup/script-history.sh)

    Описание: Выполнение скрипта script-examination-dump.sh для записи истории его выполнения. Временный скрипт необходимый для дебага.  

    Время выполнения: Каждый час в 10 минут

[Скрипт: script-examination-file.sh](/script-exemination-bakup/script-examination-file.sh)

    Описание: Проверка наличия бэкапа за прошедшый час на сервере bkp-1. Если его нет то выполняет скрипт script-examination-dump.sh

    Время выполнения: Каждый час в 25 минут 

[Скрипт: script-examination-dump2.sh](/script-exemination-bakup/script-examination-dump2.sh)

    Описание: Снятие дампа с прода и проверка его. При положительной проверке сохраняет его на сервер bkp-2

    Время выполнения: Запускается скриптом script-history2.sh 

[Скрипт: script-history2.sh](/script-exemination-bakup/script-history2.sh)

    Описание: Выполнение скрипта script-examination-dump2.sh для записи истории его выполнения. Временный скрипт необходимый для дебага.

    Время выполнения: Каждый час в 40 минут

[Скрипт: script-examination-file2.sh](/script-exemination-bakup/script-examination-file2.sh)

    Описание: Проверка наличия бэкапа за прошедшый час на сервере bkp-2. Если его нет то выполняет скрипт script-examination-dump2.sh

    Время выполнения: Каждый час в 55 минут

______
[Директория: /script-keitaro-dump/](/script-keitaro-dump/)

[Скрипт: script-keitaro-dump.sh](/script-keitaro-dump/script-keitaro-dump.sh)

    Описание: Снятие дампа с сервиса keitaro и сохранение его на сервер bkp-2 

    Время выполнения: 1 и 15 числа каждого месяца

____
[Директория: /script-status-patroni/](/script-status-patroni/)

[Скрипт: status-patroni1.sh](/script-status-patroni/status-patroni1.sh)

    Описание: Проверка состояния кластера psql. Проверяется что master patroni 1

    Время выполнения: Каждую минуту если master patroni 1. Если master patroni 2 то скрипт не выполняется. 
 

[Скрипт: status-patroni2.sh](/script-status-patroni/status-patroni2.sh)

    Описание: Проверка состояния кластера psql. Проверяется что master patroni 2

    Время выполнения: Каждую минуту если master patroni 2. Если master patroni 1 то скрипт не выполняется. 

Описание директории с логами /var/log/script/ 

    .

    ├── script-backup-keitaro - директория для логов скрипта на снятие дампа с кейтаро

    │    └── log-script-backup-keitaro - лог файл скрипта на снятие дампа с кейтаро

    ├── script_clear - директория для логов скрипта на очистку места на серверах

    │    └── script-clear - лог файл скрипта на очистку места на серверах

    ├── script-bakup-bookmaker-dir - директория для логов скрипта по снятию дампа директории bookmaker/

    │    └──  log-script-bakup-bookmaker-dir - лог файл скрипта по снятию дампа директории bookmaker/ и скрипта проверки наличия дампа

    └── script-examination-dump - директория для логов скрипта проверки снятого дампа

        ├── log-script-examination-dump - лог файл скрипта проверки снятого дампа

        ├── errorlog-script-examination-dump - директория для логов при неудачной проверке дампа

        │   └── errorlog-script-examination-dump - лог файл. При неудачной проверке сюда запишется лог с последними 15 записями из столбца created_at таблицы odds

        └── script-history - директория логов скрипта script-histori

            │   └──  log-script-history - лог файл скрипта script-histori. В нем история выполнения скрипта проверки дампа. Необходимо для дебага

            └── dump-log - директория с логами разворота дампа при выполнении скрипта  проверки дампа. 

                └── log-dump - лог файл. Если дамп развернется без ошибок то лог удалаяется если с ошибкой то остается для разследования. 
         
