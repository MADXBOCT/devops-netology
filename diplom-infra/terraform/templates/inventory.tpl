[all:children]
k8s_masters
k8s_workers1
k8s_workers2

[k8s_masters]
%{ for ip in k8s_masters ~}
${ip}
%{ endfor ~}

[k8s_workers1]
%{ for ip in k8s_workers1 ~}
${ip}
%{ endfor ~}

[k8s_workers2]
%{ for ip in k8s_workers2 ~}
${ip}
%{ endfor ~}

[all:vars]
ansible_ssh_private_key_file = ${path_to_private_key}