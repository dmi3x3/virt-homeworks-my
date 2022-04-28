# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД: **\l[+]   [PATTERN]      list databases**
- подключения к БД: **\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo} connect to new database (currently "postgres")**
- вывода списка таблиц: **\dt[S+] [PATTERN]      list tables**
- вывода описания содержимого таблиц: **\dS+ table_name**   
- выхода из psql: **\q quit psql**


## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

```jql
test_database=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```jql
test_database=# select attname, avg_width from pg_stats where tablename='orders';
 attname | avg_width 
---------+-----------
 id      |         4
 title   |        16
 price   |         4
(3 rows)
```

искомый столбец - title, его наибольшее среднее значение - 16 байт.

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

Транзакция будет состоять из следующих этапов:
* начало транзакции
* переименование таблицы orders
* создание новой партиционированной таблицы orders
* создание партиций, по заданным параметрам
* заполнение таблицы новой orders, данными из старой 
* конец транзакции.

```jql
test_database=# BEGIN;
ALTER table orders rename to orders_parent;
create table orders (id integer, title varchar(80), price integer) partition by range(price);
create table orders_before499 partition of orders for values from (0) to (499);
create table orders_after499 partition of orders for values from (499) to (999999999);
insert into orders (id, title, price) select * from orders_parent;
COMMIT;
BEGIN
ALTER TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
INSERT 0 8
COMMIT
test_database=# \d orders
                Partitioned table "public.orders"
 Column |         Type          | Collation | Nullable | Default 
--------+-----------------------+-----------+----------+---------
 id     | integer               |           |          | 
 title  | character varying(80) |           |          | 
 price  | integer               |           |          | 
Partition key: RANGE (price)
Number of partitions: 2 (Use \d+ to list them.)
```
Да, можно было сразу сделать шардированную таблицу.

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

```shell
root@2967af862920:/# pg_dump -U postgres -d test_database | gzip > /backup/test_database_dump.sql.gz
или
root@2967af862920:/# pg_dump -U postgres -d test_database > /backup/test_database_dump.sql
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

на предпоследней строке в файле бекапа надо добавить команду создания индекса, учитывая, что таблица партиционированная.

```jql
\с test_database;
CREATE INDEX title_idx ON ONLY orders (title);
CREATE INDEX CONCURRENTLY title_before499_idx ON orders_before499 (title);
CREATE INDEX CONCURRENTLY title_after499_idx ON orders_after499 (title);
ALTER INDEX title_idx ATTACH PARTITION title_before499_idx;
ALTER INDEX title_idx ATTACH PARTITION title_after499_idx;
```

или вместо этого уникальный составной индекс по полям title и price

```jql
\c test_database;
CREATE UNIQUE INDEX ON orders (title,price);
```

### Доработка

Задание 4.

в общем случае, для обычной таблицы достаточно в файле бекапа найти место, где создается таблица и добавить "NOT NULL UNIQUE" к описанию поля title.

```jql
CREATE TABLE public.orders (
    id integer,
    title character varying(80) NOT NULL UNIQUE,
    price integer
)
PARTITION BY RANGE (price);
```

Но для партиционированных таблиц существуют ограничения.

https://postgrespro.ru/docs/postgresql/13/ddl-partitioning#DDL-PARTITIONING-CONSTRAINT-EXCLUSION
###### 5.11.2.3. Ограничения
С секционированными таблицами связаны следующие ограничения:

Ограничения уникальности (а значит и первичные ключи) в секционированных таблицах должны включать все столбцы ключа разбиения. Это требование объясняется тем, что отдельные индексы, образующие ограничение, могут непосредственно обеспечивать уникальность только в своих секциях. Поэтому сама структура секционирования должна гарантировать отсутствие дубликатов в разных секциях.

Создать ограничение-исключение, охватывающее всю секционированную таблицу, нельзя; можно только поместить такое ограничение в каждую отдельную секцию с данными. И это также является следствием того, что установить ограничения, действующие между секциями, невозможно.

Триггеры BEFORE ROW для INSERT не могут менять секцию, в которую в итоге попадёт новая строка.

Смешивание временных и постоянных отношений в одном дереве секционирования не допускается. Таким образом, если секционированная таблица постоянная, такими же должны быть её секции; с временными таблицами аналогично. В случае с временными отношениями все таблицы дерева секционирования должны быть из одного сеанса.

Установим ограниччение уникальности в отдельных секциях шардированной таблицы, для этого потребуется добавить "NOT NULL UNIQUE" в таблицах-партициях:

```jql
CREATE TABLE public.orders_before499 (
    id integer,
    title character varying(80) NOT NULL UNIQUE,
    price integer
);

CREATE TABLE public.orders_after499 (
    id integer,
    title character varying(80) NOT NULL UNIQUE,
    price integer
);
```

и вставку значений производить именно в них, учитывая в логике программы условие шардирования таблиц


```jql
INSERT INTO orders_after499 (id, price, title) VALUES (12, 551, 'TEST_STRING1');
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---