1 \
`vagrant@ubuntu:~$ type cd`
cd is a shell builtin \
 команда cd встроенна в оболочку \
вполне логично, что выполняясь, команда cd в пределах этой же сессии меняет указать на директорию, записывая значение в переменную окружения PWD \
видно как она меняется если посмотреть значение через `echo $PWD` или `env`

2 \
Без pipe посчитать кол-во вхождений строки в файле можно вызвав grep c ключом -c или --count

3 \
pstree -p \
ответ systemd \
![](img/systemd.png)

4 \
откроем вторую ssh сессию через `vagrant ssh` \
запросим через ls несуществующий каталог \
запуск в первом терминале `ls /tmp/qqqqqq 2>/dev/pts/1` приведет к выводу на втором\
ls: cannot access '/tmp/qqqqqq': No such file or directory

5 \
получится. создадим файл, поместим в него текст, направим файл на подсчет кол-ва строк а результат запишем в другой файл \
```bash
vagrant@ubuntu:/tmp$ echo "hello world"> file.txt
vagrant@ubuntu:/tmp$ wc -l <file.txt >out.txt`
vagrant@ubuntu:/tmp$ cat out.txt`
1
```
6 \
пока на том tty не залогинен пользователь - получаем ошибку Permission denied
как вариант, переключиться на соседний tty по ctrl-alt-F<номер tty>, залогиниться, вернуться в графику и повторить вывод

7 \
Команда выполнена. Создает новый кастомный файловый дескриптор 5. Весь поток, следующий в него будет перенаправляться в поток с индексом 1, то есть stdout \
Так происхолдит, потому что команда echo выводит слово netology и направляет его в дескриптор 5, который связан с stdout. 
такой же результат будет если просто выполнить `echo netology`, без промежуточного файлового дескриптора

8 \
получится.
стандартный pipe
`vagrant@vagrant:/$ cat /tmp/qqq | wc -l`
`cat: /tmp/qqq: No such file or directory`
`0`

решение:
`vagrant@vagrant:/$ cat /tmp/qqq 3>&2 2>&1 1>&3 | wc -l`
`1` \
3>&2 промежуточный дескриптор 3 - перенаправил его поток stderr
2>&1 поток stderr перенаправил в stdout
1>&3 поток stdout перенаправил в промежуточный дескриптор 3

9 \
команда `cat /proc/$$/environ` выведет переменные окружения.\
аналоги команды `env` или `printenv` (при этом вывод будет более читаем, не в одну строчку как в случае с cat)

10 \
man proc
`/proc/<PID>/cmdline` - содержит полную строку запуска процесса с идентификатором <PID> (полный путь и ключи) до тех пор пока процесс НЕ зомби
`/proc/<PID>/exe` - Linux ядро 2.2 и более поздние: содержит символическую ссылку на исполняемый файл; Linux ядро 2.0 и более ранние: указатель на бинарный файл, который был запущен

11 \
`grep sse /proc/cpuinfo` \
macmini: SSE4.2, apple air m1: конечно там нет sse инструкций, вывод сильно отличается


12 \
``` bash
vagrant@netology1:~$ ssh localhost 'tty' 
not a tty
```
Так происходит, потому что данная конструкция предназначена для удаленного выполнения команд, при этом по-умолчанию не происходит выделение псевдо-терминала. \
чтобы изменить поведение нужно выполнить команду с ключом -t, который форсирует его назначение (man ssh)

```bash
vagrant@vagrant:~$ ssh -t localhost 'tty'
vagrant@localhost's password: 
/dev/pts/1
Connection to localhost closed.
```

13 \
Первый ssh терминал:
```bash
ssh vagrant
vagrant@vagrant:~$ tty
/dev/pts/0
top
````
начинает выполняться top, жмем Ctrl+Z
```bash
[1]+  Stopped                 top
vagrant@vagrant:~$ bg
[1]+ top &
vagrant@vagrant:~$ jobs -l
jobs -l
[1]+ 15227 Stopped (signal)        top
```
второй ssh терминал:
```bash
ssh vagrant
vagrant@vagrant:~$ tty
/dev/pts/1
vagrant@vagrant:~$ screen
vagrant@vagrant:~$ tty
/dev/pts/2
vagrant@vagrant:~$ reptyr 15219
```
результат: top перехвачен

для успешного выполнения задания так же понадобилось 
1. установить reptyr командой `sudo apt install reptyr`
2. выполнить `sudo sysctl kernel.yama.ptrace_scope=0` (ядро по-умолчанию иначе не разрешает прехват)

14 \
команда tee счтывает stdin и выодит значение одновременно в stdout и файл, который указывается в параметре \
запущенная (sudo) с правами суперпользователя она может записать в /root/new_file строку string
результат: \
```bash
vagrant@vagrant:~$ echo string | sudo tee /root/new_file
string
vagrant@vagrant:~$ sudo cat /root/new_file
string
vagrant@vagrant:~$ 
```


