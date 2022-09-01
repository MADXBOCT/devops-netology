1 \

https://hub.docker.com/repository/docker/madxboct/devops-netology
решение тег 0.4

2 \

- Высоконагруженное монолитное java веб-приложение;
раздробить на микросервисы для контейеров без вмешательства в код не получится, оборачивать все в контейнер нет смысла - правки/патчи применять тяжело, докер отпадает \
остается вариант с полной аппартной виртуализацией или самый надежный и точно будет работать вариант с физ .сервером
- Nodejs веб-приложение;
вообще без проблем использовать в докере. есть практический опыт: дома на микрокомпьютере Raspberry Pi в докере работает homebridge; это эмулятор IOS Homekit API для устройств системы "умный дом", которые нативно homekit не поддерживают.
- Мобильное приложение c версиями для Android и iOS;
я так понял, что речь о том, чтобы запустить приложение в каком либо эмуляторе. здесь скорее виртуалка или физ компьютер. (хотя! есть вотакие проекты: sickcodes/Docker-OSX и sickcodes/dock-droid, там внутри QEMU, для тестирования мобильного приложения может и подойти)
- Шина данных на базе Apache Kafka;
для продуктива лучше виртуалка, для тестов пойдет докер
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
все варианты возможны. в хабе докера есть официальные контейнеры от Elastic Team. (они так и говорят Bare metal? Containers? We're there.)
- Мониторинг-стек на базе Prometheus и Grafana;
все варианты возможны. от докера только плюсы - скорость развертывания и масштабируемость.
- MongoDB, как основное хранилище данных для java-приложения;
можно и в докере, для хранения данных нужно обязательно подключить volume.
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.
gitlab можно в докере, нужно пробросить 3 volume: config, logs, data; есть один важный момент! для получения почтовых уведомлений придется встраивать Mail Transfer Agent в тот же контейнер

3 \

```bash
vagrant@server1:~$ mkdir ./data
vagrant@server1:~$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
vagrant@server1:~$ docker run -it -v /home/vagrant/data:/data --name my_centos -d centos
082b6cd0be8290944bc17d8e88c35b516d88789133d186c0701587fc1f17010d
vagrant@server1:~$ docker ps -a
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
082b6cd0be82   centos    "/bin/bash"   3 seconds ago   Up 2 seconds             my_centos
vagrant@server1:~$ docker run -it -v /home/vagrant/data:/data --name my_debian -d debian
0593314d736f6c124687af5dcaf1c548abe8161380d1adb68cbce031666fce19
vagrant@server1:~$ docker ps -a
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
0593314d736f   debian    "bash"        2 minutes ago   Up 2 minutes             my_debian
082b6cd0be82   centos    "/bin/bash"   2 minutes ago   Up 2 minutes             my_centos
vagrant@server1:~$ docker exec -it my_centos bash
[root@082b6cd0be82 /]# cd data
[root@082b6cd0be82 data]# vi qqq1.txt
[root@082b6cd0be82 data]# cat qqq1.txt 
qqq1
[root@082b6cd0be82 data]# exit
exit
vagrant@server1:~$ cd data
vagrant@server1:~/data$ ls
qqq1.txt
vagrant@server1:~/data$ echo qqq2 > qqq2.txt
vagrant@server1:~/data$ cat qqq2.txt 
qqq2
vagrant@server1:~/data$ ls
qqq1.txt  qqq2.txt
vagrant@server1:~/data$ docker exec -it my_debian bash
root@0593314d736f:/# cd /data/
root@0593314d736f:/data# ls
qqq1.txt  qqq2.txt
root@0593314d736f:/data#
```

4 \
https://hub.docker.com/repository/docker/madxboct/devops-netology
не очень красиво получилось конечно. в одном репозитории 2 разных продукта с разными тегами. тег 0.6 решение 4 задания.