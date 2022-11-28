provider "yandex" {
 # service_account_key_file = ""
 # cloud_id                 = ""
 # folder_id                = ""
 # export YC_TOKEN=$(yc iam create-token)
 # export YC_CLOUD_ID=$(yc config get cloud-id)
 # export YC_FOLDER_ID=$(yc config get folder-id)

zone = "ru-central1-b"
}

# Network
resource "yandex_vpc_network" "default" {
  name = "net"
}

resource "yandex_vpc_subnet" "default" {
  name = "subnet"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.101.0/24"]
}

#image
data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2204-lts"
}

locals {
  web_instance_type_map = {
    stage = "t3_micro"
    prod  = "t3_large"
  }
}

variable "current_settings" {
  type = list(object({
    cur_cpu = number

  }))
}

instance_type = local.web_instance_type_map[terraform.workspace]

resource "yandex_compute_instance" "web" {
  name                      = "qqq"
  #hostname                  = "my-tf-server1.netology.yc"
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
      image_id    = data.yandex_compute_image.ubuntu_image.id
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.default.id}"
    nat        = true
    #ip_address = "192.168.101.11"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/ya-cloud.pub")}"
  }
}