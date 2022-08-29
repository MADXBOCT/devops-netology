1 \
1.1 
- ускорение разработки, тестирования и вывода продукта: не нужно ждать покупки железа, разработку и тестирование новой фичи можно начать немедленно  прикупив немного мощностей в облаке; не нужно ждать пока админ настроит 20 виртуалок, их можно быстренько развернуть заранее приготовленным кодом
- консистентность продуктовой, тестовой и среды разработки; подход позволяет вовсе запретить прямые изменения в какой-либо инфраструктуре. только через коммиченный код. исключает сценарий "подбац на лайве без заявки"
- масштабируемость: если система мониторинга определяет повышенную нагрузку (высокий сезон, наплыв клиенто и т.д.) можно быстро добавить производительности системе, накупив мощности в облаках и так же отказаться от простаивающих мощностей эконмя бюджет

1.2 \
все есть код. конфиги, плейбуки и прочее - все должно быть в git. даже cisco коммутаторы могут быть настроены используя IaaC. \
за счет этого достигается идемпотентность - инфраструктура из кода всегда разворачивается одинаковая

2 
2.1
 - Anisble не требует разворачивания PKI. работает на текущей SSH инфраструктуре. ssh server - стандарт де-факто для Linux
 - push модель не требует специальной подготовки образа - установки агента, который должен подключаться к серверу управления
 - не требуется специальный сервер управления, управлять можно прямо с рабочего компьютера (git + ansible + сетевая доступность) 

2.2

push более надежен и удобен чем pull \
- не нужно переживать запустился или нет агент и смог ли он подключиться к серверу управления
- предположим по каким-то причинам нужно изменить адрес сервера управления: в таком случае придется переделывать образы ос - заменить везде

3 \
Домашние работы часто выполняю на Apple MacBook M1, поэтому вместо virtualbox использовал vmware fusion tech preview \
`Professional Version e.x.p (19431034)` \
`Vagrant 2.2.19` \
`ansible [core 2.13.3]` \
4 \
для выполнения задачи скопировал src каталог, Vagrantfile заменил секцию virtualbox на vmware, заменил исходный образ на совместимы с arm процессором
```bash
madxboct@Sergejs-MacBook-Air vagrant % vagrant up
Bringing machine 'server1.netology' up with 'vmware_desktop' provider...
==> server1.netology: Cloning VMware VM: 'bytesguy/ubuntu-server-20.04-arm64'. This can take some time...
==> server1.netology: Checking if box 'bytesguy/ubuntu-server-20.04-arm64' version '1.0.0' is up to date...
==> server1.netology: Verifying vmnet devices are healthy...
==> server1.netology: Preparing network adapters...
WARNING: The VMX file for this box contains a setting that is automatically overwritten by Vagrant
WARNING: when started. Vagrant will stop overwriting this setting in an upcoming release which may
WARNING: prevent proper networking setup. Below is the detected VMX setting:
WARNING: 
WARNING:   ethernet0.pcislotnumber = "33"
WARNING: 
WARNING: If networking fails to properly configure, it may require this VMX setting. It can be manually
WARNING: applied via the Vagrantfile:
WARNING: 
WARNING:   Vagrant.configure(2) do |config|
WARNING:     config.vm.provider :vmware_desktop do |vmware|
WARNING:       vmware.vmx["ethernet0.pcislotnumber"] = "33"
WARNING:     end
WARNING:   end
WARNING: 
WARNING: For more information: https://www.vagrantup.com/docs/vmware/boxes.html#vmx-allowlisting
==> server1.netology: Starting the VMware VM...
==> server1.netology: Waiting for the VM to receive an address...
==> server1.netology: Forwarding ports...
    server1.netology: -- 22 => 20011
    server1.netology: -- 22 => 2222
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key
    server1.netology: 
    server1.netology: Vagrant insecure key detected. Vagrant will automatically replace
    server1.netology: this with a newly generated keypair for better security.
    server1.netology: 
    server1.netology: Inserting generated public key within guest...
    server1.netology: Removing insecure key from the guest if it's present...
    server1.netology: Key inserted! Disconnecting and reconnecting using new SSH key...
==> server1.netology: Machine booted and ready!
==> server1.netology: Setting hostname...
==> server1.netology: Configuring network adapters within the VM...
==> server1.netology: Waiting for HGFS to become available...
==> server1.netology: Enabling and configuring shared folders...
    server1.netology: -- /Users/madxboct/Special/GitHub/devops-netology/HomeWorks/05-virt-02-iaac/src/vagrant: /vagrant
==> server1.netology: Running provisioner: ansible...
    server1.netology: Running ansible-playbook...

PLAY [nodes] *******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [server1.netology]

TASK [Create directory for ssh-keys] *******************************************
ok: [server1.netology]
TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: If you are using a module and expect the file to exist on the remote, see the remote_src option
fatal: [server1.netology]: FAILED! => {"changed": false, "msg": "Could not find or access '~/.ssh/id_rsa.pub' on the Ansible Controller.\nIf you are using a module and expect the file to exist on the remote, see the remote_src option"}
...ignoring

TASK [Checking DNS] ************************************************************
changed: [server1.netology]

TASK [Installing tools] ********************************************************
ok: [server1.netology] => (item=git)
ok: [server1.netology] => (item=curl)

TASK [Installing docker] *******************************************************
changed: [server1.netology]

TASK [Add the current user to docker group] ************************************
changed: [server1.netology]

PLAY RECAP *********************************************************************
server1.netology           : ok=7    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1   

madxboct@Sergejs-MacBook-Air vagrant % vagrant ssh
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-92-generic aarch64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Mon 29 Aug 2022 08:11:40 PM UTC

  System load:  0.02               Users logged in:          0
  Usage of /:   24.8% of 19.56GB   IPv4 address for docker0: 172.17.0.1
  Memory usage: 27%                IPv4 address for enp1s1:  172.16.185.128
  Swap usage:   0%                 IPv4 address for enp1s4:  192.168.56.11
  Processes:    232


187 updates can be applied immediately.
120 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

New release '22.04.1 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Mon Aug 29 20:08:02 2022 from 172.16.185.1
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
vagrant@server1:~$
```
