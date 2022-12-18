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

docker run -dit --name centos7 spack/centos:7
docker run -dit --name ubuntu pycontribs/ubuntu:latest