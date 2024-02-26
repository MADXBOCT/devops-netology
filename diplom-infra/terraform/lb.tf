resource "yandex_lb_target_group" "tg-k8s-wk-nodes" {
  name = "tg-k8s-wk-nodes"

  dynamic "target" {
    for_each = [for s in yandex_compute_instance_group.k8s-worker.instances[*] : {
      address   = s.network_interface[0].ip_address
      subnet_id = s.network_interface[0].subnet_id
    }]

    content {
      subnet_id = target.value.subnet_id
      address   = target.value.address
    }
  }
}

resource "yandex_lb_network_load_balancer" "app-lb" {
  name = "app-lb"

  listener {
    name        = "app-lb-lst"
    port        = 80
    target_port = 30007
    external_address_spec {
      ip_version = "ipv4"
      address    = yandex_vpc_address.addr-app.external_ipv4_address[0].address
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.tg-k8s-wk-nodes.id

    healthcheck {
      name = "http"
      http_options {
        port = 30007
        path = "/"
      }
    }
  }
}