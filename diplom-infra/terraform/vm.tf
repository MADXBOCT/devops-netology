resource "yandex_compute_instance_group" "k8s-master" {
  name               = "k8s-master"
  service_account_id = "aje56burc53lo57paasf"

  instance_template {
    name = "k8s-master-{instance.index}"
    hostname = "k8s-master-{instance.index}"

    platform_id = "standard-v2"
    resources {
      memory        = 2
      cores         = 2
      core_fraction = 20
    }

    scheduling_policy {
      preemptible = "true"
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu_image.id
        size     = 10
        type = "network-ssd"
      }
    }

    network_interface {
      network_id = "${yandex_vpc_network.diplom-net.id}"
      subnet_ids = ["${yandex_vpc_subnet.public1.id}","${yandex_vpc_subnet.public2.id}","${yandex_vpc_subnet.public3.id}"]
      nat        = true
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/cicd.pub")}"
    }

    labels = {
      name = "k8s"
      role = "master"
    }

  }

  scale_policy {
      fixed_scale {
        size = 1

      }
    }

  allocation_policy {
      zones = ["ru-central1-b", "ru-central1-a", "ru-central1-d"]
    }

  deploy_policy {
      max_unavailable = 1
      max_creating    = 2
      max_expansion   = 1
      max_deleting    = 2
    }
}

resource "yandex_compute_instance" "k8s-worker" {

  service_account_id = "aje56burc53lo57paasf"

  name     = "${terraform.workspace}-k8s-node${count.index + 1}"
  hostname = "${terraform.workspace}-k8s-node${count.index + 1}"
  count = 2

    platform_id = "standard-v2"
    resources {
      memory        = 2
      cores         = 2
      core_fraction = 5
    }

    scheduling_policy {
      preemptible = "true"
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu_image.id
        size     = 10
        type = "network-ssd"
      }
    }

    network_interface {
      subnet_id = "${yandex_vpc_subnet.public2.id}"
      nat        = true
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/cicd.pub")}"
    }

    labels = {
      name = "k8s"
      role = "worker"
    }


   provisioner "remote-exec" {
    inline = ["echo 'SSH is up!'"]
    connection {
      host        = self.network_interface[0].nat_ip_address
      type        = "ssh"
      user        = var.SSH_USER
      private_key = file(var.PATH_TO_PRIVATE_KEY)
      timeout = "10m"
    }
  }


}