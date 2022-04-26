# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
```shell
FROM centos:7
LABEL elasticsearch Dmitriy Kapustin
ENV PATH=/usr/lib:$PATH

#RUN yum install java-1.8.0-openjdk.x86_64
RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

RUN echo -e '[elasticsearch]\nname=Elasticsearch repository for 7.x packages\nbaseurl=https://artifacts.elastic.co/packages/7.x/yum\ngpgcheck=1\ngpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch\nenabled=0\nautorefresh=1\ntype=rpm-md' > /etc/yum.repos.d/elasticsearch.repo

RUN yum install -y --enablerepo=elasticsearch elasticsearch 
    
ADD elasticsearch.yml /etc/elasticsearch/
RUN mkdir /usr/share/elasticsearch/snapshots /var/lib/logs /var/lib/data && chown elasticsearch:elasticsearch /usr/share/elasticsearch/snapshots /var/lib/logs /var/lib/data

USER elasticsearch
CMD ["/usr/sbin/init"]
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
```
- ссылку на образ в репозитории dockerhub

[image_elasticsearch-7_from_centos:7](https://hub.docker.com/r/dmi3x3/elastic7_image/tags)

- ответ `elasticsearch` на запрос пути `/` в json виде
```shell
{
  "name" : "88f79c9b5b0f",
  "cluster_name" : "netology_test",
  "cluster_uuid" : "0akLZNkxR_-LkUMhDRebgA",
  "version" : {
    "number" : "7.17.3",
    "build_flavor" : "default",
    "build_type" : "rpm",
    "build_hash" : "5ad023604c8d7416c9eb6c0eadb62b14e766caff",
    "build_date" : "2022-04-19T08:11:19.070913226Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

```shell
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases pEe5pZ2tRfidu2lgtiaUgw   1   0         40            0     37.9mb         37.9mb
green  open   ind-1            MPAysxBqQFOAt8-9XhjoJw   1   0          0            0       226b           226b
yellow open   ind-3            9HEWTM-oSZeO6FsYfmq_xg   4   2          0            0       904b           904b
yellow open   ind-2            _otGoER7TgySP9ZIT1CApg   2   1          0            0       452b           452b
```
Получите состояние кластера `elasticsearch`, используя API.
```shell
bash-4.2$ curl -X GET 'http://localhost:9200/_cluster/health/?pretty' 
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
bash-4.2$ curl -X GET 'http://localhost:9200/_cluster/health/ind-1?pretty' 
{
  "cluster_name" : "netology_test",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
bash-4.2$ curl -X GET 'http://localhost:9200/_cluster/health/ind-2?pretty' 
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
bash-4.2$ curl -X GET 'http://localhost:9200/_cluster/health/ind-3?pretty' 
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```
Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
    
    Часть индексов в состоянии yellow потому, что у них параметр unassigned_shards больше 0 
    это говорит о том, что количество реплик больше количества серверов для их размещения.

Удалите все индексы.

bash-4.2$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```shell
bash-4.2$ curl -XPOST localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/usr/share/elasticsearch/snapshots" }}'
{
  "acknowledged" : true
}
bash-4.2$ curl -XGET 'http://localhost:9200/_snapshot/netology_backup?pretty'
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/usr/share/elasticsearch/snapshots"
    }
  }
}
```
Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```shell
bash-4.2$ curl -X GET localhost:9200/_cat/indices?v     
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  vUN2WF1_SLG0L35Yn1bOSg   1   0          0            0       226b           226b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.
```shell
curl -X PUT localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
```

**Приведите в ответе** список файлов в директории со `snapshot`ами.
```shell
bash-4.2$ ls -lh /usr/share/elasticsearch/snapshots/
total 48K
-rw-r--r-- 1 elasticsearch elasticsearch 1.2K Apr 26 08:35 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 Apr 26 08:35 index.latest
drwxr-xr-x 5 elasticsearch elasticsearch 4.0K Apr 26 08:35 indices
-rw-r--r-- 1 elasticsearch elasticsearch  29K Apr 26 08:35 meta-PykQRJbMSzaQLto4P6tTIA.dat
-rw-r--r-- 1 elasticsearch elasticsearch  625 Apr 26 08:35 snap-PykQRJbMSzaQLto4P6tTIA.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```shell
bash-4.2$ curl -X GET localhost:9200/_cat/indices?v
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 p-qoeVv3S8CJl3rkQlQJNg   1   0          0            0       226b           226b
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

    При восстановлении с указанием минимальных параметров могут возникнуть ошибки.
    
```shell
curl -X POST localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d'{"include_global_state":true}'
{
  "error" : {
    "root_cause" : [
      {
        "type" : "snapshot_restore_exception",
        "reason" : "[netology_backup:elasticsearch/PykQRJbMSzaQLto4P6tTIA] cannot restore index [.ds-.logs-deprecation.elasticsearch-default-2022.04.26-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"
      }
    ],
    "type" : "snapshot_restore_exception",
    "reason" : "[netology_backup:elasticsearch/PykQRJbMSzaQLto4P6tTIA] cannot restore index [.ds-.logs-deprecation.elasticsearch-default-2022.04.26-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"
  },
  "status" : 500
}
```

```bash
bash-4.2$ curl -X POST localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d'{"include_global_state":true}'
{
  "error" : {
    "root_cause" : [
      {
        "type" : "snapshot_restore_exception",
        "reason" : "[netology_backup:elasticsearch/PykQRJbMSzaQLto4P6tTIA] cannot restore index [.ds-ilm-history-5-2022.04.26-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"
      }
    ],
    "type" : "snapshot_restore_exception",
    "reason" : "[netology_backup:elasticsearch/PykQRJbMSzaQLto4P6tTIA] cannot restore index [.ds-ilm-history-5-2022.04.26-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"
  },
  "status" : 500
}
```
    все мешающие восстановлению индексы необходимо закрыть, после восстановления они откроются автоматически.

```shell
bash-4.2$ curl -X POST localhost:9200/.ds-.logs-deprecation.elasticsearch-default-2022.04.26-000001/_close
{"acknowledged":true,"shards_acknowledged":true,"indices":{".ds-.logs-deprecation.elasticsearch-default-2022.04.26-000001":{"closed":true}}}
curl -X POST localhost:9200/.ds-ilm-history-5-2022.04.26-000001/_close
{"acknowledged":true,"shards_acknowledged":true,"indices":{".ds-ilm-history-5-2022.04.26-000001":{"closed":true}}}
bash-4.2$ curl -X POST localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d'{"include_global_state":true}'
bash-4.2$ curl -X GET localhost:9200/_cat/indices?v
health status index         uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2        p-qoeVv3S8CJl3rkQlQJNg   1   0          0            0       226b           226b
green  open   test          7yVKYbZGTt654PfrdWHusQ   1   0          0            0       226b           226b
```


    Так же есть можно переименовать индексы в момент восстановления 
```shell
bash-4.2$ сurl -X POST localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d' {  "indices": "*", "ignore_unavailable": true, "include_aliases": false, "include_global_state": false, "rename_pattern": "(.+)", "rename_replacement": "restored_$1"}'
bash-4.2$ curl -X GET localhost:9200/_cat/indices?v
health status index         uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2        p-qoeVv3S8CJl3rkQlQJNg   1   0          0            0       226b           226b
green  open   restored_test ediGwGO5S46pEDyVMCPnkg   1   0          0            0       226b           226b
```
    Затем индексы переименовываются еще раз, получая требуемые имена.
```shell
bash-4.2$ curl -X POST 'localhost:9200/_reindex' -H 'Content-Type: application/json' -d'{"source": { "index": "restored_test"}, "dest": { "index": "test" } }'
```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---