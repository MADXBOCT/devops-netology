provider "yandex" {
  zone = "ru-central1-b"
}

#image
data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2204-lts"
}

resource "null_resource" "web_hosts_provision" {
  depends_on = [yandex_compute_instance_group.k8s-master]

#  provisioner "local-exec" {
#    command = "echo '${var.PATH_TO_PRIVATE_KEY}' | ssh-add -"
#  }

  provisioner "local-exec" {
    command = <<-EOA
      echo "${templatefile("ansible_inventory.yml.tftpl",
        { hosts = yandex_compute_instance.web[*] })}" > hosts.yml
    EOA
  }

  provisioner "local-exec" {
    command     = "ansible-playbook -i hosts.yml provision.yml"
    interpreter = ["bash"]
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    triggers    = { always_run = "${timestamp()}" }
  }

}