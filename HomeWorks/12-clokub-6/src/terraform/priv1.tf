#public-vm
resource "yandex_compute_instance" "private-1" {
  name = "private-1"
  hostname                  = "private-1"
  allow_stopping_for_update = true

  resources {
    cores  = "2"
    memory = "1"
    core_fraction = "5"
  }

  platform_id = "standard-v2"

  scheduling_policy {
    preemptible = "true"
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.ubuntu_image.id
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.private.id}"
#    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/cicd.pub")}"
  }
}
