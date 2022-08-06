1 \
качаем и распаковываем
```bash
vagrant@ubuntu:~$ cd /tmp
vagrant@ubuntu:/tmp$ wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-arm64.tar.gz
<...>
2022-07-16 08:49:38 (872 KB/s) - ‘node_exporter-1.3.1.linux-arm64.tar.gz’ saved [8339932/8339932]
vagrant@ubuntu:/tmp$ tar -xzvf ./node_exporter-1.3.1.linux-arm64.tar.gz 
node_exporter-1.3.1.linux-arm64/
node_exporter-1.3.1.linux-arm64/LICENSE
node_exporter-1.3.1.linux-arm64/NOTICE
node_exporter-1.3.1.linux-arm64/node_exporter
```
создаем unit файл, запускаем node_exporter,помещаем в автозагрузку; EnvironmentFile в конфиге пишем как в примере с cron через `=-` данная конструкция позволит продолжить запуск службы, если конфиг с экстра-опциями существовать не будет
```bash
vagrant@ubuntu:/tmp$ sudo cp node_exporter-1.3.1.linux-arm64/node_exporter /usr/sbin
vagrant@ubuntu:/tmp$ sudo nano /etc/systemd/system/node_exporter.service
vagrant@ubuntu:/tmp$ cat /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter

[Service]
EnvironmentFile=-/etc/default/node_exporter
ExecStart=/usr/sbin/node_exporter $MY_OPTS

[Install]
WantedBy=multi-user.target
vagrant@ubuntu:/tmp$sudo -i
root@ubuntu:~# systemctl start node_exporter
root@ubuntu:~# systemctl enable node_exporter
Created symlink /etc/systemd/system/multi-user.target.wants/node_exporter.service → /etc/systemd/system/node_exporter.service.
root@ubuntu:~# systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; disabled; vendor preset: enabled)
     Active: active (running) since Sat 2022-07-16 09:29:23 UTC; 2min 9s ago
   Main PID: 4249 (node_exporter)
      Tasks: 5 (limit: 2224)
     Memory: 5.0M
     CGroup: /system.slice/node_exporter.service
             └─4249 /usr/sbin/node_exporter
root@ubuntu:~# systemctl stop node_exporter
root@ubuntu:~# systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Sat 2022-07-16 09:56:57 UTC; 3s ago
    Process: 4249 ExecStart=/usr/sbin/node_exporter $MY_OPTS (code=killed, signal=TERM)
   Main PID: 4249 (code=killed, signal=TERM)
root@ubuntu:~# shutdown -r now
<-=reboot=->
vagrant@ubuntu:~$ sudo systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2022-07-16 09:53:19 UTC; 1min 5s ago
   Main PID: 823 (node_exporter)
      Tasks: 4 (limit: 2224)
     Memory: 13.7M
     CGroup: /system.slice/node_exporter.service
             └─823 /usr/sbin/node_exporter             
```
2 \
`curl http://127.0.0.1:9100/metrics | less`

CPU:
```bash
node_cpu_seconds_total{cpu="0",mode="idle"} 612.3
node_cpu_seconds_total{cpu="0",mode="system"} 3.95
node_cpu_seconds_total{cpu="0",mode="user"} 1.99
````
MEM
```bash
node_memory_MemAvailable_bytes 1.82263808e+09
node_memory_MemFree_bytes 1.521856512e+09
```
Disk
```bash
node_disk_io_now{device="nvme0n1"} 0
node_disk_read_time_seconds_total{device="nvme0n1"} 3.95
node_disk_write_time_seconds_total{device="nvme0n1"} 1.486
```
Net
```baash
node_network_receive_bytes_total{device="enp1s1"} 249088
node_network_receive_drop_total{device="enp1s1"} 0
node_network_receive_errs_total{device="enp1s1"} 0
node_network_transmit_bytes_total{device="enp1s1"} 212427
node_network_transmit_drop_total{device="enp1s1"} 0
node_network_transmit_errs_total{device="enp1s1"} 0
```


3 \
`sudo apt install -y netdata`
`sudo nano /etc/netdata/netdata.conf`
добавляем секцию, тк она полностью отсуствует
```bash
[web]
        default port = 19999
        bind to = 0.0.0.0
```
порт проброшен
```bash
==> default: Waiting for the VM to receive an address...
==> default: Forwarding ports...
    default: -- 19999 => 19999
    default: -- 22 => 2222
```

![](img/netdata.png)

4 \
Да можно. на apple m1 вывод следующий:
```bash
vagrant@ubuntu:/tmp$ dmesg | grep virtual
[    3.601256] systemd[1]: Detected virtualization vmware.
```

5 
```bash
vagrant@vagrant:~$ sysctl -n fs.nr_open
1048576
```
Максимальное кол-во открытых дескрипторов, так называемое системное ограничение. \
Другое ограничение:
```bash
vagrant@vagrant:~$ ulimit -Sn
1024
```
S - soft - "мягкое" ограничение, применяется на пользователя; можно изменить в большую сьторону

6 
```bash
root@vagrant:~# unshare -f --pid --mount-proc sleep 1h
root@vagrant:~# ps ax | grep sleep
   2030 pts/0    S      0:00 sleep 1h
root@vagrant:~# nsenter --target 2030 --pid --mount
root@vagrant:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   7228   520 pts/0    S    19:24   0:00 sleep 1h
root           2  0.0  0.4   8960  4112 pts/0    S    19:26   0:00 -bash
root          13  0.0  0.3  10612  3252 pts/0    R+   19:26   0:00 ps aux
```
7

:(){ :|:& };:

для понятности заменим : именем f и отформатируем код.
```bash
f() {
  f | f &
}
f
```
таким образом это функция, которая параллельно пускает два своих экземпляра. Каждый пускает ещё по два и т.д.

`[ 8741.064445] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-1.scope` \
отработал механизм Process Number Controller в Linux Control Groups

```bash
vagrant@vagrant:~$ systemctl status user-1000.slice
● user-1000.slice - User Slice of UID 1000
     Loaded: loaded
    Drop-In: /usr/lib/systemd/system/user-.slice.d
             └─10-defaults.conf
     Active: active since Sat 2022-08-06 17:06:38 UTC; 3h 16min ago
       Docs: man:user@.service(5)
      Tasks: 8 (limit: 2345)
     Memory: 120.1M
     CGroup: /user.slice/user-1000.slice
             ├─session-1.scope
             │ ├─ 1296 sshd: vagrant [priv]
             │ ├─ 1342 sshd: vagrant@pts/0
             │ ├─ 1343 -bash
             │ ├─ 2030 sleep 1h
             │ ├─44741 systemctl status user-1000.slice
             │ └─44742 pager
             └─user@1000.service
               └─init.scope
                 ├─1308 /lib/systemd/systemd --user
                 └─1309 (sd-pam)
```    
таким образом находим limit: 2345
пробуем разобраться откуда взялось это число
```bash
vagrant@vagrant:~$ cat /usr/lib/systemd/system/user-.slice.d/10-defaults.conf
#  SPDX-License-Identifier: LGPL-2.1+
#
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.

[Unit]
Description=User Slice of UID %j
Documentation=man:user@.service(5)
After=systemd-user-sessions.service
StopWhenUnneeded=yes

[Slice]
TasksMax=33%
```
по-умолчанию `TasksMax=33%`, который задается либо числом либо процентом от общесистемного лимита


команда `sudo systemctl set-property user-1000.slice TasksMax=500` позволяет переопределить это значение
```bash
vagrant@vagrant:~$ systemctl status user-1000.slice
● user-1000.slice - User Slice of UID 1000
     Loaded: loaded
    Drop-In: /usr/lib/systemd/system/user-.slice.d
             └─10-defaults.conf
             /etc/systemd/system.control/user-1000.slice.d
             └─50-TasksMax.conf
     Active: active since Sat 2022-08-06 17:06:38 UTC; 3h 26min ago
       Docs: man:user@.service(5)
      Tasks: 7 (limit: 500)
```

Другой вариант ограничения - ulimit \
по-умолчанию пользователю разрешается запстить не более 3554 процесса
```bash
vagrant@vagrant:~$ ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 3554
max locked memory       (kbytes, -l) 65536
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 3554
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```
установить другое значение `ulimit -u`