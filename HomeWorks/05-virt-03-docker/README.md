1 \

https://hub.docker.com/repository/docker/madxboct/devops-netology
решение тег 0.4

2 \

- Высоконагруженное монолитное java веб-приложение;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- Шина данных на базе Apache Kafka;
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;
- MongoDB, как основное хранилище данных для java-приложения;
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

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