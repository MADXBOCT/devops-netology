## Описание Group Vars
Добавлен файл `lighthouse/vars.yml`, который содержит некоторые переменные

### Описание lighthouse/vars.yml
 - `lighthouse_url`  - url для скачивания дистрибутива (сайт статики) lighthouse
 - `arc_name` -  название архивного файла после скачивания, с которым дальше предстоит работать
 - `tmp_fld` - расположение временного каталога
 - `websrv_home` - расположение root каталога веб-сервера nginx 

## Описание Play
Добавлен play *Install lighthouse*.
Установлены тэги *lighthouse* для дальнейшего использования и отладки.

### Описание *Install lighthouse*
 - установка вебсервера nginx
 - скачивание архива с lighthouse
 - удаление контента по-умолчанию из root каталога nginx
 - установка unzip
 - разархивирование содержимого архива во временный каталог
 - перемещение веб-сайта в root каталог nginx
 - запуск вебсервера nginx

## Результаты выполнения playbook
### Локально в docker контейнере (*inventory/test.yml*)

Команда для запуска контейнеров
```bash
docker run -dit -p 8123:8123 --name clickhouse-01 centos:7 && \
docker run -dit --name vector-01 centos:7 && \
docker run -dit -p 19080:80 --name lighthouse-01 ubuntu:22.04
```

Команда и результат выполнения playbook
```bash
➜  playbook git:(main) ✗ ansible-playbook -i inventory/test.yml site.yml --tags lighthouse                        

PLAY [Install Clickhouse] ****************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:23:24 +0300 (0:00:00.026)       0:00:00.026 ****** 
ok: [clickhouse-01]

PLAY [Install vector] ********************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:23:29 +0300 (0:00:05.253)       0:00:05.280 ****** 
ok: [vector-01]

PLAY [Install lighthouse] ****************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:23:33 +0300 (0:00:03.847)       0:00:09.128 ****** 
ok: [lighthouse-01]

TASK [Install nginx] *********************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:23:35 +0300 (0:00:02.531)       0:00:11.659 ****** 
changed: [lighthouse-01]

TASK [Download Lighthouse from remote URL] ***********************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:23:58 +0300 (0:00:22.383)       0:00:34.043 ****** 
changed: [lighthouse-01]

TASK [Prepare Nginx folder] **************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:24:01 +0300 (0:00:03.777)       0:00:37.820 ****** 
changed: [lighthouse-01]

TASK [Install unzip] *********************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:24:03 +0300 (0:00:01.450)       0:00:39.271 ****** 
changed: [lighthouse-01]

TASK [Extract lighthouse] ****************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:24:11 +0300 (0:00:08.461)       0:00:47.732 ****** 
changed: [lighthouse-01]

TASK [Move extracted content] ************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:24:15 +0300 (0:00:03.210)       0:00:50.943 ****** 
changed: [lighthouse-01]

TASK [Start NGiNX] ***********************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:24:16 +0300 (0:00:01.390)       0:00:52.333 ****** 
changed: [lighthouse-01]

PLAY RECAP *******************************************************************************************************************************************************************************************************************************************************************
clickhouse-01              : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
lighthouse-01              : ok=8    changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

Saturday 21 January 2023  18:24:18 +0300 (0:00:01.668)       0:00:54.002 ****** 
=============================================================================== 
Install nginx -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 22.38s
Install unzip --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 8.46s
Gathering Facts ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 5.25s
Gathering Facts ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 3.85s
Download Lighthouse from remote URL ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 3.78s
Extract lighthouse ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 3.21s
Gathering Facts ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 2.53s
Start NGiNX ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 1.67s
Prepare Nginx folder -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 1.45s
Move extracted content ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 1.39s
➜  playbook git:(main) ✗ 
```

### На виртульной машине в YaCloud (*inventory/prod.yml*)
Команда и результат выполнения playbook

```bash 
➜  playbook git:(main) ✗ ansible-playbook -i inventory/prod.yml site.yml --tags lighthouse
[WARNING]: Could not match supplied host pattern, ignoring: clickhouse

PLAY [Install Clickhouse] ****************************************************************************************************************************************************************************************************************************************************
skipping: no hosts matched
[WARNING]: Could not match supplied host pattern, ignoring: vector

PLAY [Install vector] ********************************************************************************************************************************************************************************************************************************************************
skipping: no hosts matched

PLAY [Install lighthouse] ****************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:53:11 +0300 (0:00:00.027)       0:00:00.027 ****** 
The authenticity of host '158.160.11.130 (158.160.11.130)' can't be established.
ED25519 key fingerprint is SHA256:VOezMqtW/emsxh/Do3n+ZP6IdyOE5z4GQeZ7kDAho+M.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
ok: [lighthouse-01]

TASK [Install nginx] *********************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:53:31 +0300 (0:00:19.607)       0:00:19.635 ****** 
changed: [lighthouse-01]

TASK [Download Lighthouse from remote URL] ***********************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:55:14 +0300 (0:01:43.129)       0:02:02.765 ****** 
changed: [lighthouse-01]

TASK [Prepare Nginx folder] **************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:55:18 +0300 (0:00:03.449)       0:02:06.215 ****** 
changed: [lighthouse-01]

TASK [Install unzip] *********************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:55:20 +0300 (0:00:01.902)       0:02:08.117 ****** 
changed: [lighthouse-01]

TASK [Extract lighthouse] ****************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:56:07 +0300 (0:00:47.414)       0:02:55.531 ****** 
changed: [lighthouse-01]

TASK [Move extracted content] ************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:56:12 +0300 (0:00:05.511)       0:03:01.043 ****** 
changed: [lighthouse-01]

TASK [Start NGiNX] ***********************************************************************************************************************************************************************************************************************************************************
Saturday 21 January 2023  18:56:14 +0300 (0:00:01.830)       0:03:02.874 ****** 
ok: [lighthouse-01]

PLAY RECAP *******************************************************************************************************************************************************************************************************************************************************************
lighthouse-01              : ok=8    changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

Saturday 21 January 2023  18:56:17 +0300 (0:00:02.835)       0:03:05.709 ****** 
=============================================================================== 
Install nginx ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 103.13s
Install unzip -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 47.41s
Gathering Facts ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 19.61s
Extract lighthouse ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 5.51s
Download Lighthouse from remote URL ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 3.45s
Start NGiNX ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 2.84s
Prepare Nginx folder -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 1.90s
Move extracted content ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 1.83s
➜  playbook git:(main) ✗
```