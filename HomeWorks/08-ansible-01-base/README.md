1 \
ответ: 12
```bash
playbook git:(main) ansible-playbook -i inventory/test.yml site.yml

PLAY [Print os facts] **************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
[WARNING]: Platform darwin on host localhost is using the discovered Python interpreter at /usr/bin/python3, but future installation of another Python interpreter could change the meaning of that path.
See https://docs.ansible.com/ansible-core/2.13/reference_appendices/interpreter_discovery.html for more information.
ok: [localhost]

TASK [Print OS] ********************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "MacOSX"
}

TASK [Print fact] ******************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP *************************************************************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

2 \
```bash
➜  playbook git:(main) cat ./group_vars/all/examp.yml 
---
  some_fact: all default fact%                                                                                                                                                                              ➜  playbook git:(main) 
```

3 \
```bash
➜  playbook git:(main) ✗ docker -v
Docker version 20.10.20, build 9fdeb9c
➜  playbook git:(main) ✗
```

4 \
```bash
docker run -dit --name centos7 centos:7
docker run -dit --name ubuntu ubuntu
docker exec -it ubuntu /bin/bash
apt update
apt install python3

➜  playbook git:(main) ✗ ansible-playbook -i inventory/prod.yml site.yml

PLAY [Print os facts] ********************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:08:52 +0300 (0:00:00.029)       0:00:00.029 ****** 
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] **************************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:08:57 +0300 (0:00:05.037)       0:00:05.066 ****** 
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ************************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:08:57 +0300 (0:00:00.120)       0:00:05.187 ****** 
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP *******************************************************************************************************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

5 
```bash
➜  playbook git:(main) ✗ cat group_vars/deb/examp.yml 
---
  some_fact: "deb default fact"                                                                                                                                                                                                                                              
➜  playbook git:(main) ✗ cat group_vars/el/examp.yml 
---
  some_fact: "el default fact"                                                                                                                                                                                                                                               
➜  playbook git:(main) ✗ 
```

6
```bash
➜  playbook git:(main) ✗ ansible-playbook -i inventory/prod.yml site.yml

PLAY [Print os facts] ********************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:15:59 +0300 (0:00:00.027)       0:00:00.027 ****** 
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] **************************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:16:04 +0300 (0:00:05.436)       0:00:05.463 ****** 
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ************************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:16:04 +0300 (0:00:00.126)       0:00:05.589 ****** 
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *******************************************************************************************************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```
7
```bash
➜  playbook git:(main) ✗ ansible-vault encrypt group_vars/deb/examp.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
➜  playbook git:(main) ✗ ansible-vault encrypt group_vars/el/examp.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
➜  playbook git:(main) ✗ 
```

8
```bash
➜  playbook git:(main) ✗ cat group_vars/el/examp.yml                   
$ANSIBLE_VAULT;1.1;AES256
36376363393134653862333639616466633763653435376134636363363562633461333366396339
3162646663643233623631313137323735623039656564330a306232303538653063353730633632
65313731623865396634613665373965343830353635373465316630623031336637326166373765
3361373063623635660a616165373635323166346361326339666665396362303339373638626639
30356430656531376337386432363763333265366261303262666135313038373766363130643564
3033323031306631346562633334393665646336316139386462
➜  playbook git:(main) ✗ cat group_vars/deb/examp.yml
$ANSIBLE_VAULT;1.1;AES256
62373062663862646465633033623233626432316336303333303132356137333263333335666463
6239623832363938613134356366653137363135616163370a346531633361353234666366383466
36316636306239383531613737636234396361643064316134376432363762373931393465383261
3563313333333766610a303364396539346665616663313434613966386237313163386262383262
39386364313164366164303536613165346662646139323335633531366237653035333766663530
3565386531343539613266646662613932386463626137323431
➜  playbook git:(main) ✗ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] ********************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:22:51 +0300 (0:00:00.069)       0:00:00.070 ****** 
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] **************************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:22:56 +0300 (0:00:04.992)       0:00:05.062 ****** 
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ************************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:22:56 +0300 (0:00:00.103)       0:00:05.166 ****** 
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *******************************************************************************************************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

Tuesday 20 December 2022  19:22:56 +0300 (0:00:00.150)       0:00:05.317 ****** 
=============================================================================== 
Gathering Facts ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 4.99s
Print fact ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 0.15s
Print OS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 0.10s
➜  playbook git:(main) ✗ 
```

9 \
local

10
```bash
➜  playbook git:(main) ✗ cat inventory/prod.yml
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local% 
```

11
```bash
➜  playbook git:(main) ✗ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] ********************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:38:31 +0300 (0:00:00.091)       0:00:00.091 ****** 
[WARNING]: Platform darwin on host localhost is using the discovered Python interpreter at /usr/bin/python3, but future installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.13/reference_appendices/interpreter_discovery.html for more information.
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] **************************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:38:36 +0300 (0:00:05.646)       0:00:05.737 ****** 
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "MacOSX"
}

TASK [Print fact] ************************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:38:36 +0300 (0:00:00.147)       0:00:05.884 ****** 
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP *******************************************************************************************************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

12
```bash
➜  playbook git:(main) ✗ cat group_vars/local/examp.yml 
---
  some_fact: local default fact%                                                                                                                                                                                                                                              ➜  playbook git:(main) ✗ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] ********************************************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:46:09 +0300 (0:00:00.068)       0:00:00.068 ****** 
[WARNING]: Platform darwin on host localhost is using the discovered Python interpreter at /usr/bin/python3, but future installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.13/reference_appendices/interpreter_discovery.html for more information.
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] **************************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:46:14 +0300 (0:00:05.253)       0:00:05.322 ****** 
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "MacOSX"
}

TASK [Print fact] ************************************************************************************************************************************************************************************************************************************************************
Tuesday 20 December 2022  19:46:14 +0300 (0:00:00.133)       0:00:05.455 ****** 
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "local default fact"
}

PLAY RECAP *******************************************************************************************************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
