1 \
Изучил. Хорошее решение для "тонких дисков" виртуальных машин, экономит место. Минус сразу - оверпровижн. пример: виртуальным машинам сделали диски по 50гб, но система занимает всего 5. сделали десяток таких машин и положи на диск объемом 100Гб. все ок. но могут быть проблемы - останов всех машин, если например они все начали отрастать из-за неправильно настроенной ротации логов. 

2 \
ответ: Так как хард-линк это ссылка на тот же самый файл с тем же inode права бужут абсолютно те же
проверка:
```bash
vagrant@vagrant:~$ touch file_for_hard_link_test
vagrant@vagrant:~$ ln file_for_hard_link_test link_for_test
vagrant@vagrant:~$ ls -ilah | grep test
1311312 -rw-rw-r-- 2 vagrant vagrant    0 Jul  9 12:52 file_for_hard_link_test
1311312 -rw-rw-r-- 2 vagrant vagrant    0 Jul  9 12:52 link_for_test
vagrant@vagrant:~$ chmod 777 file_for_hard_link_test 
vagrant@vagrant:~$ ls -ilah | grep test
1311312 -rwxrwxrwx 2 vagrant vagrant    0 Jul  9 12:52 file_for_hard_link_test
1311312 -rwxrwxrwx 2 vagrant vagrant    0 Jul  9 12:52 link_for_test
```
3 \
vm пересоздал. +2 диска sdb и sdc
```bash
vagrant@vagrant:~$ lsblk | grep sd
sda                         8:0    0   64G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0  1.5G  0 part /boot
└─sda3                      8:3    0 62.5G  0 part 
sdb                         8:16   0  2.5G  0 disk 
sdc                         8:32   0  2.5G  0 disk
```
создаем разделы sdb1=2Gb,sdb2=остальное
```bash
vagrant@vagrant:~$ sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xb5c08fca

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): 

Using default response p.
Partition number (1-4, default 1): 
First sector (2048-5242879, default 2048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xb5c08fca

Device     Boot Start     End Sectors Size Id Type
/dev/sdb1        2048 4196351 4194304   2G 83 Linux

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p):  

Using default response p.
Partition number (2-4, default 2): 
First sector (4196352-5242879, default 4196352): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879): 

Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xb5c08fca

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

vagrant@vagrant:~$ lsblk | grep sd
sda                         8:0    0   64G  0 disk 
├─sda1                      8:1    0    1M  0 part 
├─sda2                      8:2    0  1.5G  0 part /boot
└─sda3                      8:3    0 62.5G  0 part 
sdb                         8:16   0  2.5G  0 disk 
├─sdb1                      8:17   0    2G  0 part 
└─sdb2                      8:18   0  511M  0 part 
sdc                         8:32   0  2.5G  0 disk
```

копируем таблицу разделов с помощью sfdik
```bash
vagrant@vagrant:~$ sudo sfdisk -d /dev/sdb | sudo sfdisk /dev/sdc
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0xb5c08fca.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0xb5c08fca

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

```bash
6
vagrant@vagrant:~$ sudo mdadm --create /dev/md1 --level=1 --raid-devices=2 /dev/sd[bc]1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
```
7
```bash
vagrant@vagrant:~$ sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sd[bc]2
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```
8
```bash
vagrant@vagrant:~$ sudo pvcreate /dev/md0 /dev/md1
  Physical volume "/dev/md0" successfully created.
  Physical volume "/dev/md1" successfully created.
```
9
```bash
vagrant@vagrant:~$ sudo vgcreate vg2 /dev/md0 /dev/md1
  Volume group "vg2" successfully created
vagrant@vagrant:~$ sudo vgdisplay
  --- Volume group ---
  VG Name               ubuntu-vg
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <62.50 GiB
  PE Size               4.00 MiB
  Total PE              15999
  Alloc PE / Size       7999 / <31.25 GiB
  Free  PE / Size       8000 / 31.25 GiB
  VG UUID               4HbbNB-kISH-fXeQ-qzbV-XeNd-At34-cCUUuJ
   
  --- Volume group ---
  VG Name               vg2
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <2.99 GiB
  PE Size               4.00 MiB
  Total PE              765
  Alloc PE / Size       0 / 0   
  Free  PE / Size       765 / <2.99 GiB
  VG UUID               t9V6C0-IHxF-SLaP-7d2Q-a47Z-9e5d-Z9Lc98
```
10
```bash
vagrant@vagrant:~$ sudo lvcreate -L 100M vg2 /dev/md0
  Logical volume "lvol0" created.
```
11
```bash
vagrant@vagrant:~$ sudo lvcreate -L 100M vg2 /dev/md0
  Logical volume "lvol0" created.
vagrant@vagrant:~$ sudo mkfs.ext4 /dev/vg2/lvol0
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```
12
```bash
vagrant@vagrant:~$ mkdir /tmp/new
vagrant@vagrant:~$ mount /dev/vg2/lvol0 /tmp/new
mount: only root can do that
vagrant@vagrant:~$ sudo mount /dev/vg2/lvol0 /tmp/new
```
13
```bash 
vagrant@vagrant:~$ sudo wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2022-07-09 16:19:22--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 23815641 (23M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz                                100%[====================================================================================================>]  22.71M  47.4MB/s    in 0.5s    

2022-07-09 16:19:23 (47.4 MB/s) - ‘/tmp/new/test.gz’ saved [23815641/23815641]

```

14
```bash
vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 61.9M  1 loop  /snap/core20/1328
loop1                       7:1    0 43.6M  1 loop  /snap/snapd/14978
loop2                       7:2    0 67.2M  1 loop  /snap/lxd/21835
loop3                       7:3    0 61.9M  1 loop  /snap/core20/1518
loop4                       7:4    0 67.8M  1 loop  /snap/lxd/22753
sda                         8:0    0   64G  0 disk  
├─sda1                      8:1    0    1M  0 part  
├─sda2                      8:2    0  1.5G  0 part  /boot
└─sda3                      8:3    0 62.5G  0 part  
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.3G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk  
├─sdb1                      8:17   0    2G  0 part  
│ └─md1                     9:1    0    2G  0 raid1 
└─sdb2                      8:18   0  511M  0 part  
  └─md0                     9:0    0 1018M  0 raid0 
    └─vg2-lvol0           253:1    0  100M  0 lvm   /tmp/new
sdc                         8:32   0  2.5G  0 disk  
├─sdc1                      8:33   0    2G  0 part  
│ └─md1                     9:1    0    2G  0 raid1 
└─sdc2                      8:34   0  511M  0 part  
  └─md0                     9:0    0 1018M  0 raid0 
    └─vg2-lvol0           253:1    0  100M  0 lvm   /tmp/new
```

15
```bash
vagrant@vagrant:/tmp$ gzip -t /tmp/new/test.gz
vagrant@vagrant:/tmp$ echo $?
0
```
16
```bash 
vagrant@vagrant:/tmp$ sudo pvmove /dev/md0
  /dev/md0: Moved: 8.00%
  /dev/md0: Moved: 100.00%
```

17
```bash
vagrant@vagrant:/tmp$ sudo mdadm /dev/md1 --fail /dev/sdc1
mdadm: set /dev/sdc1 faulty in /dev/md1
```

18
```bash
vagrant@vagrant:/tmp$ dmesg |grep md1
[  218.659770] md/raid1:md1: not clean -- starting background reconstruction
[  218.659771] md/raid1:md1: active with 2 out of 2 mirrors
[  218.659786] md1: detected capacity change from 0 to 2144337920
[  218.659876] md: resync of RAID array md1
[  229.478509] md: md1: resync done.
[ 1272.729001] md/raid1:md1: Disk failure on sdc1, disabling device.
               md/raid1:md1: Operation continuing on 1 devices.
```
19
```bash
vagrant@vagrant:/tmp$ gzip -t /tmp/new/test.gz
vagrant@vagrant:/tmp$ echo $?
0
vagrant@vagrant:/tmp$ ls -lah /tmp/new/
total 23M
drwxr-xr-x  3 root root 4.0K Jul  9 16:19 .
drwxrwxrwt 12 root root 4.0K Jul  9 16:19 ..
drwx------  2 root root  16K Jul  9 16:17 lost+found
-rw-r--r--  1 root root  23M Jul  9 14:54 test.gz
```
20
```bash
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Destroying VM and associated drives...
```

