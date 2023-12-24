## Задание 1

### Манифест

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cfgmap
data:
  mtport: "8080"

---
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
        env:
          - name: HTTP_PORT
            valueFrom:
              configMapKeyRef:
                name: cfgmap
                key: mtport
                
---
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

###  Результат

```bash
sgudimov@VMADM2-007:~$ curl -I 192.168.127.18:30007
HTTP/1.1 200 OK
Server: nginx/1.25.3
Date: Sun, 24 Dec 2023 18:40:47 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 24 Oct 2023 13:46:47 GMT
Connection: keep-alive
ETag: "6537cac7-267"
Accept-Ranges: bytes

sgudimov@VMADM2-007:~$ curl -I 192.168.127.18:30008
HTTP/1.1 200 OK
Server: nginx/1.24.0
Date: Sun, 24 Dec 2023 18:40:49 GMT
Content-Type: text/html
Content-Length: 148
Last-Modified: Sun, 24 Dec 2023 18:39:10 GMT
Connection: keep-alive
ETag: "65887ace-94"
Accept-Ranges: bytes
```

## Задание 2

