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
- mode=4 (802.3ad) динамический режим, участвуют все интерфейсы и порты со стороны коммутатора, группа собирается автоматически, используется та же настройка хеширования xmit_hash_policy что и в mode=2 
- mode=5 (balance-tlb) 
- mode=6 (balance-alb)
