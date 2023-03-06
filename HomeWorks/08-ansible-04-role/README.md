ansible-galaxy install -r requirements.yml
ansible-galaxy install -r requirements.yml -p roles

ansible-galaxy install -r requirements.yml --roles-path ./

➜  08-ansible-03-yandex git:(main) ansible-galaxy install -r requirements.yml --roles-path ./
Starting galaxy role install process
- extracting clickhouse to /Users/madxboct/Special/GitHub/devops-netology/HomeWorks/08-ansible-03-yandex/clickhouse
- clickhouse (1.11.0) was installed successfully
➜  08-ansible-03-yandex git:(main) 

➜  08-ansible-03-yandex git:(main) ansible-galaxy role init vector-role
- Role vector-role was created successfully
➜  08-ansible-03-yandex git:(main) 
- 