#Deploy kuber-master (control plane)
resource "yandex_compute_instance" "k8s-master" {
zone = "ru-central1-a"
  service_account_id = "aje56burc53lo57paasf"

  name     = "k8s-master-node-${count.index + 1}"
  hostname = "k8s-master-node-${count.index + 1}"
  count = 1

    platform_id = "standard-v2"
    resources {
      memory        = 2
      cores         = 2
      core_fraction = 100
    }

    scheduling_policy {
      preemptible = "false"
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu_image.id
        size     = 20
        type = "network-ssd"
      }
    }

    network_interface {
      subnet_id = yandex_vpc_subnet.public1.id
      nat        = true
    }

    metadata = {
      ssh-keys = "${var.SSH_USER}:${file(var.PATH_TO_PUBLIC_KEY)}"
    }

    labels = {
      name = "k8s"
      role = "master"
    }


#   provisioner "remote-exec" {
#    inline = ["echo 'SSH is up!'"]
#    connection {
#      host        = self.network_interface[0].nat_ip_address
#      type        = "ssh"
#      user        = var.SSH_USER
#      private_key = file(var.PATH_TO_PRIVATE_KEY)
#      timeout = "20m"
#    }
#  }


}

#Deploy kuber worker pool in zone "b"
resource "yandex_compute_instance" "k8s-worker1" {
zone = "ru-central1-b"
  service_account_id = "aje56burc53lo57paasf"

  name     = "k8s-worker1-node-${count.index + 1}"
  hostname = "k8s-worker1-node-${count.index + 1}"
  count = 1

    platform_id = "standard-v2"
    resources {
      memory        = 2
      cores         = 2
      core_fraction = 100
    }

    scheduling_policy {
      preemptible = "true"
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu_image.id
        size     = 20
        type = "network-ssd"
      }
    }

    network_interface {
      subnet_id = yandex_vpc_subnet.public2.id
      nat        = true
    }

    metadata = {
      ssh-keys = "${var.SSH_USER}:${file(var.PATH_TO_PUBLIC_KEY)}"
    }

    labels = {
      name = "k8s"
      role = "worker1"
    }


#   provisioner "remote-exec" {
#    inline = ["echo 'SSH is up!'"]
#    connection {
#      host        = self.network_interface[0].nat_ip_address
#      type        = "ssh"
#      user        = var.SSH_USER
#      private_key = file(var.PATH_TO_PRIVATE_KEY)
#      timeout = "20m"
#    }
#  }


}

#Deploy kuber worker pool in zone "d"
resource "yandex_compute_instance" "k8s-worker2" {
zone = "ru-central1-d"
  service_account_id = "aje56burc53lo57paasf"

  name     = "k8s-worker2-node-${count.index + 1}"
  hostname = "k8s-worker2-node-${count.index + 1}"
  count = 1

    platform_id = "standard-v2"
    resources {
      memory        = 2
      cores         = 2
      core_fraction = 100
    }

    scheduling_policy {
      preemptible = "true"
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu_image.id
        size     = 20
        type = "network-ssd"
      }
    }

    network_interface {
      subnet_id = yandex_vpc_subnet.public3.id
      nat        = true
    }

    metadata = {
      ssh-keys = "${var.SSH_USER}:${file(var.PATH_TO_PUBLIC_KEY)}"
    }

    labels = {
      name = "k8s"
      role = "worker2"
    }


#   provisioner "remote-exec" {
#    inline = ["echo 'SSH is up!'"]
#    connection {
#      host        = self.network_interface[0].nat_ip_address
#      type        = "ssh"
#      user        = var.SSH_USER
#      private_key = file(var.PATH_TO_PRIVATE_KEY)
#      timeout = "20m"
#    }
#  }


}