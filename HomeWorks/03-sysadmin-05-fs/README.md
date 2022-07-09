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



