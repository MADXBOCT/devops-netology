Конфигурационные файлы terraform находятся в папке src/terraform

Результат работы terraform (короткий вывод)
```bash
Ξ src/terraform git:(main) ▶ terraform apply -auto-approve
yandex_vpc_network.lab-net: Refreshing state... [id=enputbkg5s4qr7e5vlkf]
data.yandex_compute_image.ubuntu_image: Reading...
data.yandex_compute_image.ubuntu_image: Read complete after 1s [id=fd83s8u085j3mq231ago]
yandex_vpc_subnet.public: Refreshing state... [id=e2lucgmum3ctu8b8v3pu]
yandex_vpc_route_table.lab-rt: Refreshing state... [id=enpt4rffmmekg1a0s2ce]
yandex_vpc_subnet.private: Refreshing state... [id=e2lledcndmvo3teme5c7]
yandex_compute_instance.public-1: Refreshing state... [id=epdfglaeeuap1sdmmedr]
yandex_compute_instance.nat: Refreshing state... [id=epdof23m5kn6b20aekj2]
yandex_compute_instance.private-1: Refreshing state... [id=epdjk8q4r4rbpq1se1jd]

Changes to Outputs:
  + external_ip_address_nat  = "51.250.109.56"
  + external_ip_address_pub1 = "51.250.30.31"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_nat = "51.250.109.56"
external_ip_address_pub1 = "51.250.30.31"
```

Заходим на машину public
`Ξ src/terraform git:(main) ▶ ssh ubuntu@51.250.30.31 -i ~/.ssh/cicd`

Проверяем, что доступ в интернет есть ip совпадает с публичным адресом
```bash
ubuntu@public-1:~$ ping ya.ru
PING ya.ru (5.255.255.242) 56(84) bytes of data.
64 bytes from ya.ru (5.255.255.242): icmp_seq=1 ttl=249 time=3.59 ms
64 bytes from ya.ru (5.255.255.242): icmp_seq=2 ttl=249 time=3.44 ms
ubuntu@public-1:~$ curl 2ip.io
51.250.30.31
```

Добавляем приватный ключ для входа на машину private
```bash
ubuntu@public-1:~$ vi ./.ssh/cicd
ubuntu@public-1:~$ chmod 600 ./.ssh/cicd
ubuntu@public-1:~$ ssh ubuntu@192.168.20.16 -i ./.ssh/cicd 
```
Проверяем, что доступ в интернет есть, ip совпадает с NAT иннстансом
```bash
ubuntu@private-1:~$ ping ya.ru
PING ya.ru (77.88.55.242) 56(84) bytes of data.
64 bytes from ya.ru (77.88.55.242): icmp_seq=1 ttl=247 time=0.967 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=2 ttl=247 time=0.478 ms
ubuntu@private-1:~$ curl 2ip.io
51.250.109.56
```