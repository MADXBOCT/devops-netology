resource "yandex_vpc_network" "diplom-net" {
  name = "diplom-net"

}

#resource "yandex_vpc_subnet" "public1" {
#  name = "public1"
#  v4_cidr_blocks = ["192.168.10.0/24"]
#  zone           = "ru-central1-a"
#  network_id     = "${yandex_vpc_network.diplom-net.id}"
#
#}
#
#resource "yandex_vpc_subnet" "public2" {
#  name = "public2"
#  v4_cidr_blocks = ["192.168.20.0/24"]
#  zone           = "ru-central1-b"
#  network_id     = "${yandex_vpc_network.diplom-net.id}"
#
#}
#
#resource "yandex_vpc_subnet" "public3" {
#  name = "public3"
#  v4_cidr_blocks = ["192.168.30.0/24"]
#  zone           = "ru-central1-d"
#  network_id     = "${yandex_vpc_network.diplom-net.id}"
#
#}

resource "yandex_vpc_subnet" "subnet-k8s-master" {
  count          = 1
  name           = "public-k8s-master-${var.zones_master[count.index]}"
  zone           = var.zones_master[count.index]
  network_id     = yandex_vpc_network.diplom-net.id
  v4_cidr_blocks = [var.cidr[count.index]]
}

resource "yandex_vpc_subnet" "subnet-k8s-worker" {
  count          = 2
  name           = "public-k8s-worker-${var.zones_worker[count.index]}"
  zone           = var.zones_worker[count.index]
  network_id     = yandex_vpc_network.diplom-net.id
  v4_cidr_blocks = [var.cidr[count.index]]
}