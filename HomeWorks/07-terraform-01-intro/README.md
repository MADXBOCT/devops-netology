1 \


2 \
```bash
➜  devops-netology git:(main) terraform --version
Terraform v1.2.8
on darwin_arm64

Your version of Terraform is out of date! The latest version
is 1.3.1. You can update by downloading from https://www.terraform.io/downloads.html
➜  devops-netology git:(main) 
```

3 \
Для решения этой задачи существует специальная утилита tfswitch
https://github.com/warrensbox/terraform-switcher

```bash
➜  ~ terraform -v
Terraform v1.3.2
on darwin_amd64
➜  ~ tfswitch    
✔ 0.12.31
Downloading to: /Users/madxboct/.terraform.versions
29180819 bytes downloaded
Switched terraform to version "0.12.31" 
➜  ~ terraform -v
Terraform v0.12.31

Your version of Terraform is out of date! The latest version
is 1.3.2. You can update by downloading from https://www.terraform.io/downloads.html
➜  ~ 
```
или можно скачать нужную версию из архива https://releases.hashicorp.com/terraform/0.12.31/ и просто преименовать испольняемый файл