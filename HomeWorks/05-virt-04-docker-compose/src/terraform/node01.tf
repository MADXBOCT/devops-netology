resource "yandex_compute_instance" "node01" {
  name                      = "node01"
  zone                      = "ru-central1-b"
  hostname                  = "node01.netology.cloud"
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
      name        = "root-node01"
      type        = "network-ssd"
      size        = "50"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/ya-cloud.pub")}"
  }
}