Deployment nginx, multitool, service, ingress
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app.kubernetes.io/name: nginx
spec:
  replicas: 3
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

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app.kubernetes.io/name: multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: multitool
  template:
    metadata:
      labels:
        app.kubernetes.io/name: multitool
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
  name: nginx-service
spec:
  selector:
    app.kubernetes.io/name: nginx
  ports:
    - name: http-nginx-port
      protocol: TCP
      port: 9001
      targetPort: http-web-svc

---
apiVersion: v1
kind: Service
metadata:
  name: multitool-service
spec:
  selector:
    app.kubernetes.io/name: multitool
  ports:
    - name: http-multitool-port
      protocol: TCP
      port: 9002
      targetPort: multitool-8080

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-mt-ingress
#  annotations:
#    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
#  ingressClassName: nginx-example
  rules:
  - http:
      paths:
      - path: /
        pathType: Exact
        backend:
          service:
            name: nginx-service
            port:
              number: 9001
      - path: /api
        pathType: Exact
        backend:
          service:
            name: multitool-service
            port:
              number: 9002
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

```bash
sgudimov@VMADM2-007:~$ curl -I 192.168.127.18
HTTP/1.1 200 OK
Date: Mon, 06 Nov 2023 13:20:13 GMT
Content-Type: text/html
Content-Length: 615
Connection: keep-alive
Last-Modified: Tue, 24 Oct 2023 13:46:47 GMT
ETag: "6537cac7-267"
Accept-Ranges: bytes

sgudimov@VMADM2-007:~$ curl -I 192.168.127.18/api
HTTP/1.1 404 Not Found
Date: Mon, 06 Nov 2023 13:20:18 GMT
Content-Type: text/html
Content-Length: 153
Connection: keep-alive

ubuntu@srvlandevops2:~/kuber$ kubectl logs backend-5fcdcd459c-zbzws
The directory /usr/share/nginx/html is not mounted.
Therefore, over-writing the default index.html file with some useful information:
WBITT Network MultiTool (with NGINX) - backend-5fcdcd459c-zbzws - 10.1.181.200 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
Replacing default HTTP port (80) with the value specified by the user - (HTTP_PORT: 8080).
10.1.181.205 - - [06/Nov/2023:13:20:18 +0000] "HEAD /api HTTP/1.1" 404 0 "-" "curl/7.68.0" "192.168.100.227"
2023/11/06 13:20:18 [error] 17#17: *1 open() "/usr/share/nginx/html/api" failed (2: No such file or directory), client: 10.1.181.205, server: localhost, request: "HEAD /api HTTP/1.1", host: "192.168.127.18"
```