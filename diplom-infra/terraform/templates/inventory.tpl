[all:children]
k8s_masters

[k8s_masters]
%{ for ip in k8s_masters ~}
${ip}
%{ endfor ~}

[all:vars]
ansible_ssh_private_key_file = ${path_to_private_key}