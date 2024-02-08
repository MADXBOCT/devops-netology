provider "yandex" {
  zone = "ru-central1-b"
}

#image
data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
}

# After we got ip addresses of our k8s nodes we can create inventory file for ansible from a template
resource "local_file" "inventory" {
  depends_on = [yandex_compute_instance_group.k8s-master]
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      k8s_masters = yandex_compute_instance_group.k8s-master.instances[*].network_interface[0].nat_ip_address
      #k8s_workers = aws_instance.k8s-worker.*.public_ip
      path_to_private_key = var.PATH_TO_PRIVATE_KEY
    }
  )
  filename = "${path.module}/../ansible/inventory"

  # As soon inventory file is ready we can call Ansible playbook to configure k8s cluster
  provisioner "local-exec" {
    # Switching context to ansible folder
    working_dir = "${path.module}/../ansible/"
    # Run ansible-playbook, it will use freshly created inventory file
    # We use Force Color option because by default terrafrom output will be lack and white
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook k8s.yaml"
  }
}