resource "yandex_compute_instance" "node03" {
  name                      = "node03"
  zone                      = "ru-central1-b"
  hostname                  = "node03.netology.yc"
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
      image_id    = "${var.centos-7-base}"
      name        = "root-node03"
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.default.id}"
    nat        = true
    ip_address = "192.168.101.13"
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/ya-cloud.pub")}"
  }
}
