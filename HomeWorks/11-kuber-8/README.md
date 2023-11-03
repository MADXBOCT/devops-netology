### Задание1
Deployment nginx & multitool
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  labels:
    app.kubernetes.io/name: nginx-multitool
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: nginx-multitool
  template:
    metadata:
      labels:
        app.kubernetes.io/name: nginx-multitool
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: http-web-svc
      - name: multitool
        image: wbitt/network-multitool
        ports:
        - containerPort: 8080
          name: multitool-8080
        env:
          - name: HTTP_PORT
            value: "8080"
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-multitool-service
spec:
  selector:
    app.kubernetes.io/name: nginx-multitool
  ports:
    - name: http-nginx-port
      protocol: TCP
      port: 9001
      targetPort: http-web-svc
    - name: http-multitool-port
      protocol: TCP
      port: 9002
      targetPort: multitool-8080

```

```bash
ubuntu@srvlandevops2:~/kuber$ kubectl get pod
NAME                             READY   STATUS    RESTARTS   AGE
my-deployment-7bb8cd675b-dj8c4   2/2     Running   0          18s
my-deployment-7bb8cd675b-69rls   2/2     Running   0          18s
my-deployment-7bb8cd675b-jrznr   2/2     Running   0          18s
ubuntu@srvlandevops2:~/kuber$ kubectl get service
NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
kubernetes                ClusterIP   10.152.183.1    <none>        443/TCP             174d
nginx-multitool-service   ClusterIP   10.152.183.25   <none>        9001/TCP,9002/TCP   13m
```

Добавляем отдельный multitool
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multitool-separate
  labels:
    app.kubernetes.io/name: multitool-separate
spec:
  containers:
  - name: multitool-separate
    image: wbitt/network-multitool
    ports:
    - containerPort: 8080
      name: mt-sep-8080
    - containerPort: 8443
      name: mt-sep-8443
    env:
      - name: HTTP_PORT
        value: "8080"
```
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl get pod
NAME                             READY   STATUS    RESTARTS   AGE
my-deployment-7bb8cd675b-dj8c4   2/2     Running   0          14m
my-deployment-7bb8cd675b-69rls   2/2     Running   0          14m
my-deployment-7bb8cd675b-jrznr   2/2     Running   0          14m
multitool-separate               1/1     Running   0          9s

ubuntu@srvlandevops2:~/kuber$ kubectl exec -it multitool-separate -- bash
multitool-separate:/# curl nginx-multitool-service:9001 -I
HTTP/1.1 200 OK
Server: nginx/1.25.3
Date: Fri, 03 Nov 2023 17:52:36 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 24 Oct 2023 13:46:47 GMT
Connection: keep-alive
ETag: "6537cac7-267"
Accept-Ranges: bytes

multitool-separate:/# curl nginx-multitool-service:9002 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Fri, 03 Nov 2023 17:52:40 GMT
Content-Type: text/html
Content-Length: 149
Last-Modified: Fri, 03 Nov 2023 17:35:47 GMT
Connection: keep-alive
ETag: "65452f73-95"
Accept-Ranges: bytes
```

### Задание2

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-node-service
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: nginx-multitool
  ports:
    - name: node-tcp-nginx
      port: 9001
      targetPort: http-web-svc
      nodePort: 30007
    - name: node-tcp-mt
      port: 9002
      targetPort: multitool-8080
      nodePort: 30008
```

```bash
sgudimov@VMADM2-007:~$ curl -I 192.168.127.18:30007
HTTP/1.1 200 OK
Server: nginx/1.25.3
Date: Fri, 03 Nov 2023 18:06:57 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 24 Oct 2023 13:46:47 GMT
Connection: keep-alive
ETag: "6537cac7-267"
Accept-Ranges: bytes

sgudimov@VMADM2-007:~$ curl -I 192.168.127.18:30008
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Fri, 03 Nov 2023 18:07:02 GMT
Content-Type: text/html
Content-Length: 149
Last-Modified: Fri, 03 Nov 2023 17:35:46 GMT
Connection: keep-alive
ETag: "65452f72-95"
Accept-Ranges: bytes

```