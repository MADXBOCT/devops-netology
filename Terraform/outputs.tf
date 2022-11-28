output "zone" {
  value = yandex_compute_instance.web.zone
}

output "external_ip_address_stage" {
  value = yandex_compute_instance.web.network_interface[0].nat_ip_address
}

output "subnet_id" {
    value = yandex_vpc_network.default.id
}