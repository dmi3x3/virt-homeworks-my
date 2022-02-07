
# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

## Как сдавать задания

Обязательными к выполнению являются задачи без указания звездочки. Их выполнение необходимо для получения зачета и диплома о профессиональной переподготовке.

Задачи со звездочкой (*) являются дополнительными задачами и/или задачами повышенной сложности. Они не являются обязательными к выполнению, но помогут вам глубже понять тему.

Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Любые вопросы по решению задач задавайте в чате учебной группы.

---

## Задача 1

Сценарий выполнения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

Ответ: https://hub.docker.com/repository/docker/dmi3x3/nginx-netology-5.3

```bash
dmitriy@dellix:~/netology/docker$ docker run -it -d -p 8082:80 --name nginx-netology nginx:1.21.6
Unable to find image 'nginx:1.21.6' locally
1.21.6: Pulling from library/nginx
Digest: sha256:2834dc507516af02784808c5f48b7cbe38b8ed5d0f4837f16e78d00deb7e7767
Status: Downloaded newer image for nginx:1.21.6
1e5fc766bbdfc79a974af4b638ade025344c2ac7c8d53564287bc96a45f3b77b
dmitriy@dellix:~/netology/docker$ curl http://localhost:8082
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
dmitriy@dellix:~/netology/docker$ docker cp index.html nginx-netology:/usr/share/nginx/html/
dmitriy@dellix:~/netology/docker$ docker exec -it nginx-netology /bin/bash
root@1e5fc766bbdf:/# cat /usr/share/nginx/html/index.html 
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
root@1e5fc766bbdf:/# 
exit
dmitriy@dellix:~/netology/docker$ docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS                                       NAMES
1e5fc766bbdf   nginx:1.21.6               "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes   0.0.0.0:8082->80/tcp, :::8082->80/tcp       nginx-netology
dmitriy@dellix:~/netology/docker$ docker commit -m "Add index.html" -a "Dmitry Kapustin" 1e5fc766bbdf nginx-netology:work-5.3
sha256:fcfe85cda1b84c5d1e8d8988987fe766055cbb3790c18c8bff3121b8507b89aa
dmitriy@dellix:~/netology/docker$ docker login --username dmi3x3
Password: 

Login Succeeded
dmitriy@dellix:~/netology/docker$ docker tag nginx-netology:work-5.3 dmi3x3/nginx-netology-5.3:1.21.6
dmitriy@dellix:~/netology/docker$ docker push dmi3x3/nginx-netology-5.3:1.21.6
Using default tag: latest
The push refers to repository [docker.io/dmi3x3/nginx-netology-5.3]
438c9163827b: Mounted from dmi3x3/dmi3x3 
762b147902c0: Mounted from dmi3x3/dmi3x3 
235e04e3592a: Mounted from dmi3x3/dmi3x3 
6173b6fa63db: Mounted from dmi3x3/dmi3x3 
9a94c4a55fe4: Mounted from dmi3x3/dmi3x3 
9a3a6af98e18: Mounted from dmi3x3/dmi3x3 
7d0ebbe3f5d2: Mounted from dmi3x3/dmi3x3 
latest: digest: sha256:eb96eb8d0c00977bfd886a264262475783078ab4579281676b1673832fbbaafb size: 1778
dmitriy@dellix:~/netology/docker$ docker run -it -d -p 8083:80 --name nginx-netology1 dmi3x3/nginx-netology-5.3:1.21.6
93302d9665d1e83e4c09f0d7ae8b5845825106d8587239f0489b51138011d36e
dmitriy@dellix:~/netology/docker$ curl http://localhost:8083
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
dmitriy@dellix:~/netology/docker$
```

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;

  Докер вполне подойдет, java-приложения бывают капризными в настройке, версиях библиотек, поэтому удобно запускать контейнер из образа, в котором все настроено, оверхед от докера будет небольшим, дополнительное удобство проявится, если приложение ориентировано на масштабирование и (или) работу с балансировщиками, с помощью docker в этом случае можно в короткий срок, запустить несколько контейнеров с приложением с минимальным оверхедом, в сравнении с виртуальной машиной. 
- Nodejs веб-приложение;

  В данном случае выгодно использовать docker, он позволит быстро запускать подготовленный и настроенный образ, опять же с возможностью масштабирования. 
- Мобильное приложение c версиями для Android и iOS;

  В данном случае имеет смысл использовать виртуальную машину, т.к. для IOS вариантов запуска приложений в docker - нет. Для Android есть варианты запуска приложений, здесь, основное преимущество — при необходимости сборки проекта на любой другой машине, нам не нужно беспокоиться об установке всего окружения и достаточно будет скачать необходимый образ и запустить в нем сборку. Но до конца не ясно, как приложение, созданное и оттестированное в контейненре docker поведет себя на реальном железе с другой архитектурой.
- Шина данных на базе Apache Kafka;
    
  Подойдет docker, будет возможность масштабировать, быстро перезапускать при сбоях, а ткже быстро вернуться к предыдущей версии в результате неудачного обновления.
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
  
  Docker здесь удобнее, т.к. проще реализуется кластеризация и минимальные накладные расходы на вычислительные ресурсы.  
- Мониторинг-стек на базе Prometheus и Grafana;

  Как показывают наши практические работы, docker здесь вполне уместен, он позволит быстро развернуть, например мониторинг-стек для очередного проекта.
- MongoDB, как основное хранилище данных для java-приложения;

  Докер подойдет. Есть опыт запуска из docker-compose файла, стека graylog (elasticsearch, mongoDB, graylog) и использования его - работает без проблем, удобно, что можно запустить все эти сервисы на машине разработчика, а потом их же на сервере. 
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

  Вполне имеет смысл использовать в данной ситуации докер. Определенные проблемы вызывает обновление omnibus-установки GitLab, а докер образ уже собран и проверен самим вендором, это позволит с наименьшими усилиями использовать образ и с минимальными проблемами производить его обновление. Не забываем про масштабирование. Docker Registry также имеет смысл запускать в docker. 

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

```bash
dmitriy@dellix:~/netology/docker/task3$ docker run -it -d -v $(pwd)/data:/data --name centos_1 centos
0270c0abbdcabd6816bb27c6719c937b2cb7dc406c0ed1fb501387aebe370995
dmitriy@dellix:~/netology/docker/task3$ docker run -it -d -v $(pwd)/data:/data --name debian_1 debian
bc532880cd43043fc2a74fd92e52b777d2eeccbe3524df95a424cc8088037bed
dmitriy@dellix:~/netology/docker/task3$ docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED          STATUS          PORTS                                       NAMES
bc532880cd43   debian                     "bash"                   6 seconds ago    Up 6 seconds                                                debian_1
0270c0abbdca   centos                     "/bin/bash"              20 seconds ago   Up 20 seconds                                               centos_1
dmitriy@dellix:~/netology/docker/task3$ docker exec -it centos_1 /bin/bash
[root@0270c0abbdca /]# echo "add from centos" > /data/centos.txt    
[root@0270c0abbdca /]# exit
dmitriy@dellix:~/netology/docker/task3$ echo "add from host" > data/host.txt
dmitriy@dellix:~/netology/docker/task3$ docker exec -it debian_1 /bin/bash
root@bc532880cd43:/# ls -lh /data/
total 12K
-rw-r--r-- 1 root root 16 Feb  7 23:08 centos.txt
-rw-rw-r-- 1 1001 1001 14 Feb  7 23:09 host.txt
root@bc532880cd43:/# 
exit
dmitriy@dellix:~/netology/docker/task3$ ls -lh  data/
итого 12K
-rw-r--r-- 1 root    root    16 фев  8 02:08 centos.txt
-rw-rw-r-- 1 dmitriy dmitriy 14 фев  8 02:09 host.txt
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

Ответ: https://hub.docker.com/repository/docker/dmi3x3/ansible
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
