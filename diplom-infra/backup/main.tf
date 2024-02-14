provider "yandex" {
  zone = "ru-central1-b"
}

#image
data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
}

resource "time_sleep" "wait_many_seconds" {
  depends_on = [yandex_compute_instance_group.k8s-master]
  create_duration = "120s"
}

resource "null_resource" "check_ssh" {
 depends_on = [time_sleep.wait_many_seconds]
  // depends_on = [yandex_compute_instance_group.k8s-master]

  provisioner "remote-exec" {
    inline = ["echo 'SSH is up!'"]
    connection {
      host        = element(yandex_compute_instance_group.k8s-master.instances[*].network_interface[0].nat_ip_address, 0)
      type        = "ssh"
      user        = var.SSH_USER
      private_key = file(var.PATH_TO_PRIVATE_KEY)
      timeout = "10m"
    }
  }

}

resource "local_file" "inventory" {
  depends_on = [yandex_compute_instance.k8s-worker,null_resource.check_ssh]
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      k8s_masters = yandex_compute_instance_group.k8s-master.instances[*].network_interface[0].nat_ip_address
      //k8s_workers = yandex_compute_instance.k8s-worker.*.network_interface[0].nat_ip_address
      k8s_workers = yandex_compute_instance.k8s-worker[*].network_interface[0].nat_ip_address
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

# Check k8s is ready
resource null_resource check_k8s_ready {
  depends_on = [local_file.inventory]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl wait --for=condition=Ready nodes --all --timeout=600s
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

}

# Deploy monitoring layer
resource null_resource monitoring {
  depends_on = [null_resource.check_k8s_ready]

    provisioner "local-exec" {
    working_dir = "${path.module}/../monitoring"
    command = <<-EOT
      kubectl apply --server-side -f manifests/setup
      kubectl wait \
	          --for condition=Established \
	          --all CustomResourceDefinition \
	          --namespace=monitoring
      kubectl apply -f manifests/
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

}

# Check k8s monitoring is ready
resource null_resource check_k8s_mon_ready {
  depends_on = [null_resource.monitoring]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl wait --namespace=monitoring --for=condition=Ready pods --all --timeout=1200s
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

}

# Deploy application layer
resource null_resource deploy {
  depends_on = [null_resource.check_k8s_mon_ready]

  triggers = {
    always_run = "${timestamp()}"
  }

provisioner "local-exec" {
    # Switching context to app manifest folder
    # Deploy everything and wait for wordpress deployment
    working_dir = "${path.module}/../app"
    command = <<-EOT
      kubectl apply -f namespace.yaml
      kubectl apply -f pod-hello-world.yaml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}