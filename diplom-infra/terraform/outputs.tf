output "grafana_URL" {
 description = "IP Grafana access"
 value = "http://${element(yandex_compute_instance_group.k8s-master.instances[*].network_interface[0].nat_ip_address, 0)}:30010"
}

output "app_URL"  {
 description = "Appliction access"
 value = "http://${yandex_vpc_address.addr-app.external_ipv4_address[0].address}"
}