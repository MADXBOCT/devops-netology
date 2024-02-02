resource "yandex_vpc_network" "lab-net" {
  name = "lab-network"
}

resource "yandex_vpc_subnet" "public" {
  name = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.lab-net.id}"
}

resource "yandex_vpc_route_table" "lab-rt" {
  network_id = "${yandex_vpc_network.lab-net.id}"
  name = "lab-rt"
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}
    resource "yandex_vpc_subnet" "private" {
    name = "private"
    v4_cidr_blocks = ["192.168.20.0/24"]
    zone           = "ru-central1-b"
    network_id     = "${yandex_vpc_network.lab-net.id}"
    route_table_id = "${yandex_vpc_route_table.lab-rt.id}"
}
