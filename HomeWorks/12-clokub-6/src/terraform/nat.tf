#public-vm
resource "yandex_compute_instance" "nat" {
  name = "nat"
  hostname                  = "nat"
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
      image_id    = "fd87iicilakkb8r1bgnv"
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.public.id}"
    nat        = true
    ip_address = "192.168.10.254"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/cicd.pub")}"
  }
}
