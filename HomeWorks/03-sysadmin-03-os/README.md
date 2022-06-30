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
