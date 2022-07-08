1 \
Linux: `ip a`, `ip -c -br link`, более "старая" ifconfig 
```bash
vagrant@ubuntu:~$ ip -c -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
enp1s1           UP             00:0c:29:52:55:bf <BROADCAST,MULTICAST,UP,LOWER_UP> 
vagrant@ubuntu:~$ ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp1s1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:52:55:bf brd ff:ff:ff:ff:ff:ff
    inet 172.16.185.128/24 brd 172.16.185.255 scope global dynamic enp1s1
       valid_lft 1027sec preferred_lft 1027sec
    inet6 fe80::20c:29ff:fe52:55bf/64 scope link 
       valid_lft forever preferred_lft forever
vagrant@ubuntu:~$ ifconfig
enp1s1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.16.185.128  netmask 255.255.255.0  broadcast 172.16.185.255
        inet6 fe80::20c:29ff:fe52:55bf  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:52:55:bf  txqueuelen 1000  (Ethernet)
        RX packets 324720  bytes 420896582 (420.8 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 117320  bytes 8571883 (8.5 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 587  bytes 53254 (53.2 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 587  bytes 53254 (53.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vagrant@ubuntu:~$
```
Win: ipconfig /all

2 \
CDP (англ. Cisco Discovery Protocol) — проприетарный протокол второго уровня, разработанный компанией Cisco Systems, позволяющий обнаруживать подключённое (напрямую или через устройства первого уровня) сетевое оборудование Cisco, его название, версию IOS и IP-адреса. Поддерживается многими устройствами компании, почти не поддерживается сторонними производителями. 

Link Layer Discovery Protocol (LLDP) — протокол канального уровня, позволяющий сетевому оборудованию оповещать оборудование, работающее в локальной сети, о своём существовании и передавать ему свои характеристики, а также получать от него аналогичные сведения \
В Linux пакет так и называется lldpd \
lldpctl - утилита для работы с lldpd демоном

3 \
VLAN (аббр. от англ. Virtual Local Area Network) — виртуальная локальная компьютерная сеть. Предоставляет возможность логического деления коммутатора на несколько не сообщающихся между собой сетей \
использование VLAN в Ubuntu требует установленного пакета vlan, содержащего утилиту vconfig; так же ест возможность работать через утилиту ip \
`ip link add link DEVNAME name VLANNAME type vlan id VLAN-ID`, где нужно указать DEVNAME - имя родительского интерфейса, VLANNAME - имя влан-интерфейса, VLAN-ID - идентификатор (номер тега)
пример создания влана из командной строки (создает интерфейс, дальше работаем как обычно добавляем ip,маску)
```bash
vagrant@ubuntu:~$ sudo ip link add link enp1s1 name vlan100 type vlan id 100
vagrant@ubuntu:~$ ip -c -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
enp1s1           UP             00:0c:29:b0:f6:20 <BROADCAST,MULTICAST,UP,LOWER_UP> 
vlan100@enp1s1   DOWN           00:0c:29:b0:f6:20 <BROADCAST,MULTICAST> 
```
чтобы влан создался при старте системы можно занести информацию в файл `/etc/network/interfaces` (должен стоять пакет vlan)
```bash
auto vlan100
iface vlan100 inet static
        address 10.0.0.5
        netmask 255.255.255.0
        vlan_raw_device enp1s1
```
4 \
Существуют 2 основных типа агрегации портов - статический и динамический (с использованием протокола LACP) \
Типы балансировки:

- mode=0 (balance-rr) Round-Robin, пакеты распрделяются по очереди между интерфейсами входящими в lag
- mode=1 (active-backup) один интерфейс основной, другой запасной; траффик идет через основной, до тех пор пока не будет определен линк как down, тогда траффик пойдет через другой интерфейс
- mode=2 (balance-xor) балансировка осуществляется на основе вычисляемой хеш суммы, задается через xmit_hash_policy, возможные значения 
  - 0 L2, вычисляется srv mac - dst mac; режим по-умолчанию
  - 1 L3+L4 вычисляется src_port, src_ip, dst_port, dst_ip 
  - 2 L3 + L2 вычисляется src_ip, dst_ip, src_mac, dst_mac
- mode=3 (broadcast) передача осуществляется во все интерфейсы, достигается только отказоустойчивость
- mode=4 (802.3ad) динамический режим, участвуют все интерфейсы и порты со стороны коммутатора, группа собирается автоматически, используется та же настройка хеширования xmit_hash_policy что и в mode=2, требует от коммутатора настройки
- mode=5 (balance-tlb) Adaptive transmit load balancing, не требует специфичной настройки на коммутаторе. Входящие пакеты принимаются только активным сетевым интерфейсом, исходящий распределяется в зависимости от текущей загрузки каждого интерфейса.
- mode=6 (balance-alb) Тоже самое что 5, только входящий трафик тоже распределяется между интерфейсами. Не требует настройки коммутатора

вносим изменеия в уже знакомый нам файл кофигурации `/etc/network/interfaces`
```bash
iface bond0 inet static
address 10.0.0.5
netmask 255.255.255.0
network 10.0.0.0
gateway 10.0.0.254
bond_mode balance-tlb
bond_miimon 100
bond_downdelay 200
bond_updelay 200
slaves eth0 eth1
```

5 \
В сети с маской /29, всего 8 адресов, из них устроствам можно присвоить 6 \
в /24 сети будет 256/8=32 подсети с маской /29 \
```bash
vagrant@ubuntu:~$ ipcalc -b --split 6 6 6 6 10.0.0.0/24
Address:   10.0.0.0             
Netmask:   255.255.255.0 = 24   
Wildcard:  0.0.0.255            
=>
Network:   10.0.0.0/24          
HostMin:   10.0.0.1             
HostMax:   10.0.0.254           
Broadcast: 10.0.0.255           
Hosts/Net: 254                   Class A, Private Internet

1. Requested size: 6 hosts
Netmask:   255.255.255.248 = 29 
Network:   10.0.0.0/29          
HostMin:   10.0.0.1             
HostMax:   10.0.0.6             
Broadcast: 10.0.0.7             
Hosts/Net: 6                     Class A, Private Internet

2. Requested size: 6 hosts
Netmask:   255.255.255.248 = 29 
Network:   10.0.0.8/29          
HostMin:   10.0.0.9             
HostMax:   10.0.0.14            
Broadcast: 10.0.0.15            
Hosts/Net: 6                     Class A, Private Internet

3. Requested size: 6 hosts
Netmask:   255.255.255.248 = 29 
Network:   10.0.0.16/29         
HostMin:   10.0.0.17            
HostMax:   10.0.0.22            
Broadcast: 10.0.0.23            
Hosts/Net: 6                     Class A, Private Internet

4. Requested size: 6 hosts
Netmask:   255.255.255.248 = 29 
Network:   10.0.0.24/29         
HostMin:   10.0.0.25            
HostMax:   10.0.0.30            
Broadcast: 10.0.0.31            
Hosts/Net: 6                     Class A, Private Internet

Needed size:  32 addresses.
Used network: 10.0.0.0/27
Unused:
10.0.0.32/27
10.0.0.64/26
10.0.0.128/25
```

6 \
Воспользуемся 4-ым зарезервированным диапазоном 100.64.0.0 — 100.127.255.255
```bash
vagrant@ubuntu:~$ ipcalc -b --split 50 100.64.0.0/24
Address:   100.64.0.0           
Netmask:   255.255.255.0 = 24   
Wildcard:  0.0.0.255            
=>
Network:   100.64.0.0/24        
HostMin:   100.64.0.1           
HostMax:   100.64.0.254         
Broadcast: 100.64.0.255         
Hosts/Net: 254                   Class A

1. Requested size: 50 hosts
Netmask:   255.255.255.192 = 26 
Network:   100.64.0.0/26        
HostMin:   100.64.0.1           
HostMax:   100.64.0.62          
Broadcast: 100.64.0.63          
Hosts/Net: 62                    Class A

Needed size:  64 addresses.
Used network: 100.64.0.0/26
Unused:
100.64.0.64/26
100.64.0.128/25
```

7 \
Linux: \
- посмотреть таблицу можно командами `ip neighbour` или `arp`
- удаление специфичной записи `ip neigh del <ip> dev <interface>` или `arp -d <ip_address>`
- удаление всех записей `ip neigh flush all`, утилитой arp весь кэш почистить нельзя
Win:
- посмотреть таблицу можно командами `arp -a`
- удаление специфичной записи `arp -d <ip_address>`
- удаление всех записей `arp -d`