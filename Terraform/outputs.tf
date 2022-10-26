output "ya_cloud_id" {
  value = yandex_compute_instance.my-tf-server1.
}

output "zone" {
  value = yandex_compute_instance.my-tf-server1.zone
}

output "external_ip_address_my-tf-server1" {
  value = yandex_compute_instance.my-tf-server1.network_interface[0].nat_ip_address
}

output "subnet_id" {
    value = yandex_vpc_network.default.id
}