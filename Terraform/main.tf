provider "yandex" {
  service_account_key_file = ""
  cloud_id                 = "b1gemhkf41iej5re9eov"
  folder_id                = "b1gqdc5g77am21vlmc7a"
}

# Network
resource "yandex_vpc_network" "default" {
  name = "net"
}

resource "yandex_vpc_subnet" "default" {
  name = "subnet"
  zone           = "ru-central1-b"
  network_id     = ""
  v4_cidr_blocks = ["192.168.101.0/24"]
}

resource "yandex_compute_instance" "my_tf_server1" {
  name                      = "my_tf_server1"
  zone                      = "ru-central1-b"
  hostname                  = "my_tf_server1.netology.yc"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  platform_id = "standard-v2"

  scheduling_policy {
preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id    = ""
      name        = "root-node01"
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.default.id}"
    nat        = true
    ip_address = "192.168.101.11"
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/ya-cloud.pub")}"
  }
}