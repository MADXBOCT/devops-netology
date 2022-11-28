provider "yandex" {
 # service_account_key_file = ""
 # cloud_id                 = ""
 # folder_id                = ""
 # export YC_TOKEN=$(yc iam create-token)
 # export YC_CLOUD_ID=$(yc config get cloud-id)
 #

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
  web_instance_count_map = {
  stage = 1
  prod = 2
  }
}

locals {
  web_ids = toset([
    "w1",
    "w2",
  ])
}

resource "yandex_compute_instance" "web" {
  name = "web-${terraform.workspace}"
  #hostname                  = "my-tf-server1.netology.yc"
  allow_stopping_for_update = true

  count = local.web_instance_count_map[terraform.workspace]

  resources {
    cores  = "${terraform.workspace == "prod" ? 4 : 2}"
    memory = "${terraform.workspace == "prod" ? 4 : 1}"
    core_fraction = "${terraform.workspace == "prod" ? 100 : 5}"
  }

  platform_id = "standard-v2"

  scheduling_policy {
    preemptible = "${terraform.workspace == "prod" ? false : true}"
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


resource "yandex_compute_instance" "web2" {
  name = "web2-${terraform.workspace}"
  #hostname                  = "my-tf-server1.netology.yc"
  allow_stopping_for_update = true

  for_each = local.web_ids

    lifecycle {
    create_before_destroy = true
  }


    resources {
    cores  = "${terraform.workspace == "prod" ? 4 : 2}"
    memory = "${terraform.workspace == "prod" ? 4 : 1}"
    core_fraction = "${terraform.workspace == "prod" ? 100 : 5}"
  }

  platform_id = "standard-v2"

  scheduling_policy {
    preemptible = "${terraform.workspace == "prod" ? false : true}"
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