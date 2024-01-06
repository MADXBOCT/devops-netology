### Подготовка

Включаем RBAC \
`microk8s enable rbac`

Создаем приватный ключ, запрос на сертификат, выпускаем подписанный сертификат \
`openssl genrsa -out privkey.key 2048` \
`openssl req -new -key privkey.key -out ourcsr.csr -subj "/CN=qqq/O=qqqgrp"` \
`openssl x509 -req -in ourcsr.csr -CA /var/snap/microk8s/current/certs/ca.crt -CAkey /var/snap/microk8s/current/certs/ca.key -CAcreateserial -out usrcert.crt -days 365` 

Создаем пользователя, привязываем сертификат \
`kubectl config set-credentials qqq --client-certificate=usrcert.crt --client-key=privkey.key --embed-certs=true`

Создаем контекст, привязываем пользователя \
`kubectl config set-context usr --cluster=microk8s-cluster --user=qqq`

Применяем манифест
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-log-describe
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "watch", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: qqq
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-log-describe
  apiGroup: rbac.authorization.k8s.io

---
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
  - name: hello-world
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
```

Переключаемся в контеккст пользователя \
`kubectl config use-context usr`

Проверка \
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl get pod
NAME          READY   STATUS    RESTARTS   AGE
hello-world   1/1     Running   0          11m
ubuntu@srvlandevops2:~/kuber$ kubectl get service
Error from server (Forbidden): services is forbidden: User "qqq" cannot list resource "services" in API group "" in the namespace "default"
ubuntu@srvlandevops2:~/kuber$ kubectl describe pod hello-world
Name:             hello-world
Namespace:        default
Priority:         0
Service Account:  default
Node:             srvlandevops2/192.168.127.18
Start Time:       Sat, 06 Jan 2024 10:02:23 +0000
Labels:           <none>
Annotations:      cni.projectcalico.org/containerID: 61d4a7fe480c21e6fdbe1901045548829899f0dcbd78ddc9959e9c0543711469
                  cni.projectcalico.org/podIP: 10.1.181.210/32
                  cni.projectcalico.org/podIPs: 10.1.181.210/32
Status:           Running
IP:               10.1.181.210
IPs:
  IP:  10.1.181.210
Containers:
  hello-world:
    Container ID:   containerd://a14d022a49edc291384fb20f555664fad3bd826b2920335999f56937699c7bda
    Image:          gcr.io/kubernetes-e2e-test-images/echoserver:2.2
    Image ID:       gcr.io/kubernetes-e2e-test-images/echoserver@sha256:e9ba514b896cdf559eef8788b66c2c3ee55f3572df617647b4b0d8b6bf81cf19
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sat, 06 Jan 2024 10:02:24 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-bv42f (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-bv42f:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
ubuntu@srvlandevops2:~/kuber$ kubectl logs pods/hello-world
Generating self-signed cert
Generating a 2048 bit RSA private key
.......................+++
..+++
writing new private key to '/certs/privateKey.key'
-----
Starting nginx
ubuntu@srvlandevops2:~/kuber$
```


