## Задание 1

### pod манифест
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
  - name: hello-world
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
    ports:
    - containerPort: 8080
```

### Запущенный pod
```bash
ubuntu@srvlandevops2:~$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
hello-world   1/1     Running   0          2d4h
ubuntu@srvlandevops2:~$
```

### Подключение
Терминал 1
```bash
kubectl port-forward --address 0.0.0.0 hello-world 40000:8080
Forwarding from 0.0.0.0:40000 -> 8080
Handling connection for 40000
```
Терминал 2
```bash
ubuntu@srvlandevops2:~$ curl -I 127.0.0.1:40000
HTTP/1.1 200 OK
Date: Mon, 05 Jun 2023 15:54:39 GMT
Content-Type: text/plain
Connection: keep-alive
Server: echoserver
```

## Задание 2
### pod и svc манифест
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: netology-web
  labels:
    app.kubernetes.io/name: netology-web
spec:
  containers:
  - name: netology-web
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
    ports:
    - containerPort: 8080
      name: http-web-svc
---
apiVersion: v1
kind: Service
metadata:
  name: netology-svc
spec:
  selector:
    app.kubernetes.io/name: netology-web
  ports:
    - protocol: TCP
      port: 80
      targetPort: http-web-svc
```
### Запущенный pod и svc
```bash
ubuntu@srvlandevops2:~$ kubectl get pod
NAME           READY   STATUS    RESTARTS   AGE
hello-world    1/1     Running   0          2d7h
netology-web   1/1     Running   0          4m28s
ubuntu@srvlandevops2:~$ kubectl get service
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes     ClusterIP   10.152.183.1    <none>        443/TCP   25d
netology-svc   ClusterIP   10.152.183.40   <none>        80/TCP    4m34s
ubuntu@srvlandevops2:~$
```

### Подключение
Терминал 1
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl port-forward service/netology-svc 30000:80
Forwarding from 127.0.0.1:30000 -> 8080
Forwarding from [::1]:30000 -> 8080
Handling connection for 30000
```
Терминал 2
```bash
ubuntu@srvlandevops2:~$ curl -I 127.0.0.1:30000
HTTP/1.1 200 OK
Date: Wed, 07 Jun 2023 19:42:55 GMT
Content-Type: text/plain
Connection: keep-alive
Server: echoserver
```


