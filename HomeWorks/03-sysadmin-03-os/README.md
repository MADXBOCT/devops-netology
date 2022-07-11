1 \
команда `strace /bin/bash -c 'cd /tmp'` выводит много всего, в самом конце есть то что нужно
```bash
stat("/tmp", {st_mode=S_IFDIR|S_ISVTX|0777, st_size=4096, ...}) = 0
chdir("/tmp")                           = 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```
ответ: `chdir("/tmp")` - change directory

2 \
командами
```bash
strace file /dev/tty 2>&1 | less
strace file /dev/tty 2>&1 | grep openat
strace file /dev/tty 2>&1 | grep stat
```
удалось выяснить, что `file` ищет свою базу
в домашнем каталогке пользоватя
```bash
stat("/home/vagrant/.magic.mgc", 0x7ffd349a9dc0) = -1 ENOENT (No such file or directory)
stat("/home/vagrant/.magic", 0x7ffd349a9dc0) = -1 ENOENT (No such file or directory)
```
в `/etc` и `/usr/share/misc`
```bash
openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
```
3 \
примерно воспроизвести ситуацию можно так: запускаем редактор с файлом `vim qqq`, записываем несколько произвольных символов и сохраняем :w\
открываем второй терминал, находим pid vi 103803
```bash
vagrant@ubuntu:~$ ps aux | grep vi
vagrant   103803  0.0  0.4  21272  8960 pts/0    S+   17:31   0:00 vi qqq
```
находим скрытый временный файл и удаляем его
```bash
vagrant@ubuntu:~$ lsof -p 103803
vi      103803 vagrant    4u   REG  253,0    12288 532037 /home/vagrant/.qqq.swp
vagrant@ubuntu:~$ rm /home/vagrant/.qqq.swp
vagrant@ubuntu:~$ lsof -p 103803
vi      103803 vagrant    4u   REG  253,0    12288 532037 /home/vagrant/.qqq.swp (deleted)
```
ответ: зачищаем через файловый дескриптор 4
```bash
vagrant@ubuntu:~$ echo '' > /proc/103803/fd/4
vagrant@ubuntu:~$ cat /proc/103803/fd/4

```
4 \
Зомби процессы не занимают никакие ресурсы, только имеют запись в таблице процессов

5 
```bash
vagrant@vagrant:~$ dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
vagrant@vagrant:~$ sudo /usr/sbin/opensnoop-bpfcc
PID    COMM               FD ERR PATH
1225   vminfo              4   0 /var/run/utmp
628    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
628    dbus-daemon        20   0 /usr/share/dbus-1/system-services
628    dbus-daemon        -1   2 /lib/dbus-1/system-services
628    dbus-daemon        20   0 /var/lib/snapd/dbus-1/system-services/
```
на мак с м1 утилита похоже работает не совсем корректно...
```bash
vagrant@ubuntu:~$ sudo /usr/sbin/opensnoop-bpfcc
PID    COMM               FD ERR PATH
848    irqbalance          7   0 
848    irqbalance          7   0 
848    irqbalance          7   0 
739    vmtoolsd            8   0 
739    vmtoolsd            9   0 
739    vmtoolsd            8   0 
739    vmtoolsd            8   0 
739    vmtoolsd           -1   2 

```
6 \
системный вызов uname()
```bash
vagrant@ubuntu:~$ strace uname -a
uname({sysname="Linux", nodename="ubuntu", ...}) = 0
fstat(1, {st_mode=S_IFCHR|0600, st_rdev=makedev(0x88, 0x1), ...}) = 0
uname({sysname="Linux", nodename="ubuntu", ...}) = 0
uname({sysname="Linux", nodename="ubuntu", ...}) = 0
write(1, "Linux ubuntu 5.4.0-92-generic #1"..., 109Linux ubuntu 5.4.0-92-generic #103-Ubuntu SMP Fri Nov 26 16:15:10 UTC 2021 aarch64 aarch64 aarch64 GNU/Linux
) = 109
close(1)                                = 0
close(2)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```
uname 2 мануала нет на виртуалке, нашел в интернете
https://man7.org/linux/man-pages/man2/uname.2.html \
`Part of the utsname information is also accessible via
       /proc/sys/kernel/{ostype, hostname, osrelease, version,
       domainname}.`

7 \
;  разделяет последовательность команд, выполнится вся послндовательность и неважно с каким результом успешно или с ошибкой \
&& в данном случае echo hi отработает если первая команда будет иметь успех (если tmp/some_dir существует) \
нет смысла использовать set -e так как выполнение последоавтелности прервется когда первая команда test -d /tmp/some_dir вернет значение 1

8 \
`-e` выполнение последоавтелности прервется, как только одна из команд даст не нулевой результат \
`-u` обрабатывает неустановленные или неопределенные переменные как ошибку при подстановке (во время раскрытия параметра). Не применяется к специальным параметрам, таким как * или @ \
`-x` Выводит аргументы команды во время выполнения \
`-o pipefail` Возвращаемое значение - статус последней команды, которая имела ненулевой статус при выходе. Если при выходе ни одна команда не имела ненулевого статуса, значение равно нулю. \

Данный набор поможет в отладке запуска соствных команд.

9 
```bash
vagrant@vagrant:~$ ps -o stat
STAT
Ss
R+
```
R    running or runnable (on run queue) - испольняется или ожидает исполнения, + - находятся в группе foreground \
S    interruptible sleep (waiting for an event to complete) - спящий процесс, который может быть прерван, ожидает какого-то события, s - is a session leader

