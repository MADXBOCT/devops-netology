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
получится. создадим файл, поместим в него текст, направим файл на подсчет кол-ва строк а результат запишем в другой файл
`vagrant@ubuntu:/tmp$ echo "hello world"> file.txt`
`vagrant@ubuntu:/tmp$ wc -l <file.txt >out.txt`
`vagrant@ubuntu:/tmp$ cat out.txt` \
`1`

6 \

7 \
8 \
9 \
10 \
11 \
12 \
13 \
14 \