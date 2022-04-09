# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

```shell
dmitriy@dellix:/netology/code/virt-homeworks/06-db-02-sql$ docker run --name postgres-12 -d -e POSTGRES_PASSWORD=pg_netology,PGDATA=/var/lib/postgresql/data/pgdata -p 5432:5432 -v /netology/code/virt-homeworks/06-db-02-sql/data:/var/lib/postgresql/data -v /netology/code/virt-homeworks/06-db-02-sql/backup:/backup postgres:12
```

```shell
dmitriy@dellix:/netology/code/virt-homeworks/06-db-02-sql/postgres12$ cat docker-compose.yml 
version: "3.9"
services:
  postgres:
    image: postgres:12
    environment:
      POSTGRES_PASSWORD: "pg_netology"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    ports:
      - "5432:5432"
    volumes:
      - /netology/code/virt-homeworks/06-db-02-sql/data:/var/lib/postgresql/data 
      - /netology/code/virt-homeworks/06-db-02-sql/backup:/backup 
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
```jql
postgres=# \l
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges        
-----------+----------+----------+------------+------------+--------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(4 rows)
```
- описание таблиц (describe)
(clients)
```jql
test_db=# \d clients
                                  Table "public.clients"
      Column       |  Type   | Collation | Nullable |               Default               
-------------------+---------+-----------+----------+-------------------------------------
 id                | integer |           | not null | nextval('clients_id_seq'::regclass)
 Фамилия           | text    |           |          | 
 Страна проживания | text    |           |          | 
 Заказ             | integer |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "idx_country_live" btree ("Страна проживания")
Foreign-key constraints:
    "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)

```
(orders)
```jql
test_db=# \d orders
                               Table "public.orders"
    Column    |  Type   | Collation | Nullable |              Default               
--------------+---------+-----------+----------+------------------------------------
 id           | integer |           | not null | nextval('orders_id_seq'::regclass)
 Наименование | text    |           |          | 
 Цена         | integer |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)


```

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```jql
SELECT 
  grantee, table_name, privilege_type 
FROM 
  information_schema.table_privileges 
WHERE 
  grantee in ('test-admin-user','test-simple-user') 
  and table_name in ('clients','orders') order by 1,2,3; 
```
- список пользователей с правами над таблицами test_db
```jql
     grantee      | table_name | privilege_type 
------------------+------------+----------------
 test-admin-user  | clients    | DELETE
 test-admin-user  | clients    | INSERT
 test-admin-user  | clients    | REFERENCES
 test-admin-user  | clients    | SELECT
 test-admin-user  | clients    | TRIGGER
 test-admin-user  | clients    | TRUNCATE
 test-admin-user  | clients    | UPDATE
 test-admin-user  | orders     | DELETE
 test-admin-user  | orders     | INSERT
 test-admin-user  | orders     | REFERENCES
 test-admin-user  | orders     | SELECT
 test-admin-user  | orders     | TRIGGER
 test-admin-user  | orders     | TRUNCATE
 test-admin-user  | orders     | UPDATE
 test-simple-user | clients    | DELETE
 test-simple-user | clients    | INSERT
 test-simple-user | clients    | SELECT
 test-simple-user | clients    | UPDATE
 test-simple-user | orders     | DELETE
 test-simple-user | orders     | INSERT
 test-simple-user | orders     | SELECT
 test-simple-user | orders     | UPDATE
(22 rows)

```



## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

```jql
test_db=# select from orders;
--
(5 rows)

test_db=# select from clients;
--
(5 rows)

test_db=# SELECT count(*) AS exact_count FROM orders;
 exact_count 
-------------
           5
(1 row)

test_db=# SELECT count(*) AS exact_count FROM clients;
 exact_count 
-------------
           5
(1 row)

```



### Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

```jql
test_db=# update  clients set Заказ = 3 where id = 1;
UPDATE 1
test_db=# update  clients set Заказ = 4 where id = 2;
UPDATE 1
test_db=# update  clients set Заказ = 5 where id = 3;
UPDATE 1
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

```jql
test_db=# select * from clients as c where  exists (select id from orders as o where c.Заказ = o.id);
 id |       Фамилия        | Страна проживания | Заказ 
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)

```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.
```jql
test_db=# explain (ANALYZE, timing) select * from clients as c where  exists (select id from orders as o where c.Заказ = o.id);
                                                    QUERY PLAN                                                    
------------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=37.00..57.24 rows=810 width=72) (actual time=0.053..0.056 rows=3 loops=1)
   Hash Cond: (c."Заказ" = o.id)
   ->  Seq Scan on clients c  (cost=0.00..18.10 rows=810 width=72) (actual time=0.010..0.011 rows=5 loops=1)
   ->  Hash  (cost=22.00..22.00 rows=1200 width=4) (actual time=0.019..0.020 rows=5 loops=1)
         Buckets: 2048  Batches: 1  Memory Usage: 17kB
         ->  Seq Scan on orders o  (cost=0.00..22.00 rows=1200 width=4) (actual time=0.006..0.007 rows=5 loops=1)
 `Planning Time: 0.135 ms
 Execution Time: 0.082 ms`
(8 rows)
```
Ориентируемся на значение cost=37.00..57.24 в строке "Hash Join", оно показывает стоимость запроса, ее можно сравнить у нескольких вариантов запросов (выдающих требуемые данные) и выбрать из них оптимальный.
Также при добавлении опции timing можно увидеть время планирования и выполнения запроса - Planning Time: 0.135 ms и Execution Time: 0.082 ms

Сами по себе значения одного запроса мало что скажут новичку в postgres, но если их сравнить с другим похожим запросом, можно понять, какой из запросов работает быстрее, выдавая одинаковый ответ.
```jql
test_db=# explain (ANALYZE, timing) select * from clients where Заказ is not null;
                                             QUERY PLAN                                              
-----------------------------------------------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..18.10 rows=806 width=72) (actual time=0.010..0.011 rows=3 loops=1)
   Filter: ("Заказ" IS NOT NULL)
   Rows Removed by Filter: 2
 Planning Time: 0.040 ms
 Execution Time: 0.023 ms
(5 rows)

test_db=# select * from clients where Заказ is not null;
 id |       Фамилия        | Страна проживания | Заказ 
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)

```
```text
мы видим, что скорость работы этого запроса выше, а стоимость ниже.
cost=0.00..18.10
Planning Time: 0.040 ms
Execution Time: 0.023 ms
```





## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

```shell
dmitriy@dellix:/netology/code/virt-homeworks/06-db-02-sql$ docker exec -t postgres-12 pg_dump -U postgres -d test_db -f /backup/test_dp.sql
dmitriy@dellix:/netology/code/virt-homeworks/06-db-02-sql$ docker stop postgres-12
dmitriy@dellix:/netology/code/virt-homeworks/06-db-02-sql$ docker run --name postgres-12_1 -d -e POSTGRES_PASSWORD=pg_netology,PGDATA=/var/lib/postgresql/data/pgdata -p 5432:5432 -v /netology/code/virt-homeworks/06-db-02-sql/data1:/var/lib/postgresql/data -v /netology/code/virt-homeworks/06-db-02-sql/backup:/backup postgres:12
70975527a852ad9c70efa99947b92d696246bdc6281a39863c48ddc3383df367
dmitriy@dellix:/netology/code/virt-homeworks/06-db-02-sql$ docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS                                       NAMES
70975527a852   postgres:12                "docker-entrypoint.s…"   6 seconds ago   Up 5 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres-12_1

dmitriy@dellix:/netology/code/virt-homeworks/06-db-02-sql$ docker exec -t postgres-12_1 createuser -U postgres test-admin-user && docker exec -t postgres-12_1 createuser -U postgres test-simple-user && docker exec -t postgres-12_1 createdb -U postgres test_db && docker exec -t postgres-12_1 psql -U postgres -d test_db -f /backup/test_dp.sql
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval 
--------
      5
(1 row)

 setval 
--------
      5
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
GRANT
GRANT
GRANT
GRANT
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
