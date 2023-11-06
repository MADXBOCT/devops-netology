### Задание1
Deployment nginx, multitool, service
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
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

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
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
ubuntu@srvlandevops2:~/kuber$ kubectl exec -it backend-69b6879bb4-lvf25 -- bash
backend-69b6879bb4-lvf25:/# curl nginx-multitool-service:9001 -I
HTTP/1.1 200 OK
Server: nginx/1.25.3
Date: Mon, 06 Nov 2023 10:02:10 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 24 Oct 2023 13:46:47 GMT
Connection: keep-alive
ETag: "6537cac7-267"
Accept-Ranges: bytes

backend-69b6879bb4-lvf25:/# exit
exit
ubuntu@srvlandevops2:~/kuber$ kubectl exec -it frontend-775bb5bc54-8pq42 -- bash
root@frontend-775bb5bc54-8pq42:/# curl nginx-multitool-service:9002 -I
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Mon, 06 Nov 2023 10:03:06 GMT
Content-Type: text/html
Content-Length: 143
Last-Modified: Mon, 06 Nov 2023 09:58:43 GMT
Connection: keep-alive
ETag: "6548b8d3-8f"
Accept-Ranges: bytes

root@frontend-775bb5bc54-8pq42:/# exit
exit
```
### Задание2

```yaml

```

```bash

```