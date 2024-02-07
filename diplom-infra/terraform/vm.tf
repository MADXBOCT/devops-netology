#resource "yandex_compute_instance_group" "group1" {
#  name               = "lampgrp"
#  #  folder_id           = "${data.yandex_resourcemanager_folder.test_folder.id}"
#  service_account_id = "${yandex_iam_service_account.sa2.id}"
#  #  deletion_protection = true
#
#  instance_template {
#    platform_id = "standard-v2"
#    resources {
#      memory        = 2
#      cores         = 2
#      core_fraction = 5
#    }
#
#    scheduling_policy {
#      preemptible = "true"
#    }
#
#    boot_disk {
#      mode = "READ_WRITE"
#      initialize_params {
#        image_id = data.yandex_compute_image.ubuntu_image.id
#        size     = 10
#      }
#    }
#    network_interface {
#      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
#      nat        = true
#    }
#
#    metadata = {
#    ssh-keys = "ubuntu:${file("~/.ssh/cicd.pub")}"
#    user-data = "${file("cloud-init.yaml")}"
#    }
#  }
#    scale_policy {
#      fixed_scale {
#        size = 3
#      }
#    }
#
#    allocation_policy {
#      zones = ["ru-central1-b"]
#    }
#
#    deploy_policy {
#      max_unavailable = 1
#      max_creating    = 1
#      max_expansion   = 1
#      max_deleting    = 1
#    }
#
#    load_balancer {
#    target_group_name        = "target-group"
#    target_group_description = "load balancer target group"
#    }
#
#    health_check {
#      http_options {
#        port = "80"
#        path = "/"
#      }
#    }
#
#
#}