#resource "yandex_vpc_network" "lab-net" {
#  name = "lab-network"
#
#}
#
#resource "yandex_vpc_subnet" "public" {
#  name = "public"
#  v4_cidr_blocks = ["192.168.10.0/24"]
#  zone           = "ru-central1-b"
#  network_id     = "${yandex_vpc_network.lab-net.id}"
#
#}