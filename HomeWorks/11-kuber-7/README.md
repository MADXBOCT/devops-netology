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
  replicas: 1
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
        - containerPort: 8443
          name: multitool-8443
        env:
          - name: HTTP_PORT
            value: "8080"
          - name: HTTPS_PORT
            value: "8443"
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
      port: 2080
      targetPort: http-web-svc
    - name: http-multitool-port
      protocol: TCP
      port: 1080
      targetPort: multitool-8080
    - name: https-multitool-port
      protocol: TCP
      port: 1443
      targetPort: multitool-8443

```

```bash
ubuntu@srvlandevops2:~/kuber$ kubectl get pod
NAME                             READY   STATUS    RESTARTS   AGE
my-deployment-56b796667d-pq76m   2/2     Running   0          94m
ubuntu@srvlandevops2:~/kuber$
```
Увеличиваем кол-во реплик
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl scale deployment my-deployment --replicas=2
deployment.apps/my-deployment scaled
ubuntu@srvlandevops2:~/kuber$ kubectl get pod
NAME                             READY   STATUS              RESTARTS   AGE
my-deployment-56b796667d-pq76m   2/2     Running             0          108m
my-deployment-56b796667d-ppkwc   0/2     ContainerCreating   0          4s
ubuntu@srvlandevops2:~/kuber$ kubectl get pod
NAME                             READY   STATUS    RESTARTS   AGE
my-deployment-56b796667d-pq76m   2/2     Running   0          108m
my-deployment-56b796667d-ppkwc   2/2     Running   0          9s
ubuntu@srvlandevops2:~/kuber$
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
      - name: HTTPS_PORT
        value: "8443"
```
```bash
multitool-separate:/# curl nginx-multitool-service:1080 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Tue, 17 Oct 2023 21:37:29 GMT
Content-Type: text/html
Content-Length: 150
Last-Modified: Tue, 17 Oct 2023 21:25:12 GMT
Connection: keep-alive
ETag: "652efbb8-96"
Accept-Ranges: bytes

multitool-separate:/# curl nginx-multitool-service:2080 -I
HTTP/1.1 200 OK
Server: nginx/1.25.2
Date: Tue, 17 Oct 2023 21:37:34 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 15 Aug 2023 17:03:04 GMT
Connection: keep-alive
ETag: "64dbafc8-267"
Accept-Ranges: bytes

multitool-separate:/# curl nginx-multitool-service:1443 -I
HTTP/1.1 400 Bad Request
Server: nginx/1.24.0
Date: Tue, 17 Oct 2023 21:37:39 GMT
Content-Type: text/html
Content-Length: 255
Connection: close

multitool-separate:/#
```

### Задание2
Создаем Deployment c Init контейнером
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment-2
  labels:
    app.kubernetes.io/name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: nginx
  template:
    metadata:
      labels:
        app.kubernetes.io/name: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: http-web-svc
      initContainers:
        - name: init-nginx-service
          image: busybox
          command: ['sh', '-c', "until nslookup nginx-service.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
```
Ожидание создания сервиса
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl get po
NAME                               READY   STATUS     RESTARTS   AGE
my-deployment-2-7b9887bdd9-xknvn   0/1     Init:0/1   0          12s
```
Создаем сервис
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app.kubernetes.io/name: nginx
  ports:
    - name: http-nginx-port
      protocol: TCP
      port: 2080
      targetPort: http-web-svc
```
Запуск основного контейнера
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl get po
NAME                               READY   STATUS            RESTARTS   AGE
my-deployment-2-7b9887bdd9-xknvn   0/1     PodInitializing   0          29s
ubuntu@srvlandevops2:~/kuber$ kubectl get po
NAME                               READY   STATUS    RESTARTS   AGE
my-deployment-2-7b9887bdd9-xknvn   1/1     Running   0          31s
```