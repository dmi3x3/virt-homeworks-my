# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

```shell
mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)
```

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

```jql
mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```

**Приведите в ответе** количество записей с `price` > 300.
```jql
1 row in set (0.00 sec)
```

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

```jql
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER='test';
+------+-----------+-------------------------------------------------+
| USER | HOST      | ATTRIBUTE                                       |
+------+-----------+-------------------------------------------------+
| test | localhost | {"Имя": "James", "Фамилия": "Pretty"}           |
+------+-----------+-------------------------------------------------+
1 row in set (0,00 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

```jql
         Engine: InnoDB
```

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`
```jql
mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0,04 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0,04 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+----------------------------------------------+
| Query_ID | Duration   | Query                                        |
+----------+------------+----------------------------------------------+
|       1 | 0.03443000 | ALTER TABLE orders ENGINE = MyISAM            |
|       2 | 0.04445450 | ALTER TABLE orders ENGINE = InnoDB            |
+----------+------------+----------------------------------------------+
2 rows in set, 1 warning (0,00 sec)

```
## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

```shell
dmitriy@dellix:/netology/code/virt-homeworks/06-db-03-mysql/mysql$ cat /home/dmitriy/netology_1/my.cnf 
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL
# Custom config should go here
!includedir /etc/mysql/conf.d/
#Устанавливаем запись буфера не после каждой транзакции и не в кеш операционной системы, а 
#1 - любая завершенная транзакция будет синхронно сбрасывать лог на диск. Это вариант по-умолчанию, он является самым надежным с точки зрения сохранности данных, но самым медленным по скорости работы.
#2 - лог сбрасывается не на диск, а в кеш операционной системы (т.е. не происходит flush после каждой операции). 
#    При этом лог пишется на диск с задержкой в несколько секунд, что весьма безопасно с точки зрения сохранности данных.
#0 - лог сбрасывается на диск независимо от транзакций, что дает наибольшую скорость, но при этом очень велик риск получить сломаную БД например при внезапном отлючении сервера.
innodb_flush_log_at_trx_commit = 0

#Set compression
# Barracuda - формат файла с сжатием
innodb_file_format=Barracuda

#innodb_file_per_table = ON default after mysql 5.6

#Set log buffer size
innodb_log_buffer_size	= 1M

#Set buffer pool size
#примерно echo $((30 *  $(free | awk '/Память:/{print $2}')/100 ))
innodb_buffer_pool_size = 629145 

#Set log size
innodb_log_file_size = 100M
```
---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
