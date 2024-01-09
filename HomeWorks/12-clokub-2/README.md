### Подготовка к установке k8s

Выполнена на заранее подготовленных виртулках с помощью ansible-playbook

```yaml
- name: Prepare for kuber
  hosts: cloudimg
  become: yes
  become_user: root
  remote_user: ubuntu
  tasks:

    - name: Set modeprob overlay
      shell: modprobe overlay

    - name: Set modeprob netfilter
      shell: modprobe br_netfilter

    - name: Add k8s GPG apt Key
      apt_key:
        url: https://packages.cloud.google.com/apt/doc/apt-key.gpg
        state: present

    - name: Add k8s Repository
      apt_repository:
        repo: deb http://apt.kubernetes.io/ kubernetes-xenial main
        state: present

    - name: Install k8s
      apt:
        name: '{{item}}'
        update_cache: yes
        state: latest
      with_items:
        - kubelet
        - kubeadm
        - kubectl
        - containerd
    
    - ansible.posix.sysctl:
        name: net.ipv4.ip_forward
        value: '1'
        sysctl_set: true
        state: present
        reload: true
```

### kubnode1 (master)

Инициализируем кластер, копируем конфиг, запускам сетевой плагин

```bash
sudo kubeadm init --apiserver-advertise-address=$(hostname --ip-address) \
--pod-network-cidr 10.244.0.0/16

Your Kubernetes control-plane has initialized successfully!

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml
```

### kubnode2-5 (worker)

```bash
kubeadm join 192.168.127.22:6443 --token dusvn2.yvraxmu1vu12lljc \
        --discovery-token-ca-cert-hash sha256:02553b3e1fb102c2f21e2f3ac33bd1bf473d44758a97c046ec68ba269ecd77fb
        
This node has joined the cluster:
```

### Результат

```bash
ubuntu@kubnode1:~$ kubectl get no
NAME       STATUS   ROLES           AGE   VERSION
kubnode1   Ready    control-plane   99m   v1.28.2
kubnode2   Ready    <none>          98m   v1.28.2
kubnode3   Ready    <none>          58m   v1.28.2
kubnode4   Ready    <none>          58m   v1.28.2
kubnode5   Ready    <none>          57m   v1.28.2
ubuntu@kubnode1:~$ kubectl get po -A
NAMESPACE          NAME                                       READY   STATUS    RESTARTS   AGE
calico-apiserver   calico-apiserver-685f9cdbb9-fj7f7          1/1     Running   0          62m
calico-apiserver   calico-apiserver-685f9cdbb9-tvf4j          1/1     Running   0          62m
calico-system      calico-kube-controllers-6b5c7d968b-qxbcm   1/1     Running   0          85m
calico-system      calico-node-6n7bw                          1/1     Running   0          58m
calico-system      calico-node-fj4gr                          1/1     Running   0          58m
calico-system      calico-node-n55dc                          1/1     Running   0          85m
calico-system      calico-node-srjmx                          1/1     Running   0          85m
calico-system      calico-node-xb87c                          1/1     Running   0          58m
calico-system      calico-typha-77cf678457-ndjxr              1/1     Running   0          85m
calico-system      calico-typha-77cf678457-qzvhb              1/1     Running   0          58m
calico-system      calico-typha-77cf678457-xmqtp              1/1     Running   0          57m
calico-system      csi-node-driver-89lzf                      2/2     Running   0          85m
calico-system      csi-node-driver-8rltt                      2/2     Running   0          58m
calico-system      csi-node-driver-pdgh7                      2/2     Running   0          58m
calico-system      csi-node-driver-ppwxc                      2/2     Running   0          85m
calico-system      csi-node-driver-tc5hb                      2/2     Running   0          58m
kube-system        coredns-5dd5756b68-cpsfx                   1/1     Running   0          99m
kube-system        coredns-5dd5756b68-mtpmg                   1/1     Running   0          99m
kube-system        etcd-kubnode1                              1/1     Running   1          99m
kube-system        kube-apiserver-kubnode1                    1/1     Running   1          99m
kube-system        kube-controller-manager-kubnode1           1/1     Running   0          99m
kube-system        kube-proxy-2jj5l                           1/1     Running   0          58m
kube-system        kube-proxy-47kxj                           1/1     Running   0          98m
kube-system        kube-proxy-fmg6t                           1/1     Running   0          58m
kube-system        kube-proxy-kcf2c                           1/1     Running   0          99m
kube-system        kube-proxy-pts5d                           1/1     Running   0          58m
kube-system        kube-scheduler-kubnode1                    1/1     Running   1          99m
tigera-operator    tigera-operator-55585899bf-dzscx           1/1     Running   0          93m
ubuntu@kubnode1:~$
```