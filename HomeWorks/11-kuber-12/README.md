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

### Генерим серт и приватный ключ
`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server-key.pem -out server.pem -subj "/CN=qqq.local/O=qqq.local"`
`cat server.pem | base64`
`cat server-key.pem | base64`

### Манифест
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: scr-tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURNVENDQWhtZ0F3SUJBZ0lVWUVDdld2aS9hT3JXZUFFVjNWUVkxN3Fac3Bzd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0tERVNNQkFHQTFVRUF3d0pjWEZ4TG14dlkyRnNNUkl3RUFZRFZRUUtEQWx4Y1hFdWJHOWpZV3d3SGhjTgpNak14TWpJMU1UYzFNREUxV2hjTk1qUXhNakkwTVRjMU1ERTFXakFvTVJJd0VBWURWUVFEREFseGNYRXViRzlqCllXd3hFakFRQmdOVkJBb01DWEZ4Y1M1c2IyTmhiRENDQVNJd0RRWUpLb1pJaHZjTkFRRUJCUUFEZ2dFUEFEQ0MKQVFvQ2dnRUJBTW5hZS9FdUszMzhmMjNTRzc0YTNCbk5rZkxCemtVZUxGbXZZZHAxT0pPZ040Snh1K2JyUUxsQwp1eS9MQTlvYkpleXBIcXJCKzVBMTkxbVpVZmkwVit3S0Q0SzZEbXBIVkpjN3BBNjIwWDJxQWs5bHJLYVlTcy9NClcwZWtiakxqWjdEaWJMSmIvamdBN25XL2gxL2JHOWlvOU9idWIzUWM4d1FoK0dSbHFVbWlFN21xRXJDUm5ma3kKQzRsQkhkNlVDSisvNlNFL1BlY1JnL0x2UHN6ZlhOc1lEUEZ3R3BheGphZ1VxMGoxc0lTeXMyeHh2QUk2NjFqQQpJSUNWam9FLy9hdWljTUM3RWY5OWhjdXpZSkM3Vkg1WlY4eFhjUFMxbGZrcDhXeGIxSEkyUGJQUG5laW8zQ0pOCmZlYWdNTmFOTDF0UEFuRFlRY3JCczNSS2xPV0JWMDhDQXdFQUFhTlRNRkV3SFFZRFZSME9CQllFRkV2KzF3NDcKNFk3eEN4U0dDU2psaE8yL3pyWE1NQjhHQTFVZEl3UVlNQmFBRkV2KzF3NDc0WTd4Q3hTR0NTamxoTzIvenJYTQpNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBSms3aGZCYW1RWkc2NGtlCkJqQUlhWWkzU2lCbG85TlVYSkVQQkFiUDVYVGxPazR6OVEvL2ZvdGd3aE0za2YrNzhKaVdQYmNHbFJJdGNRMEwKZkpxbGo4dU9yNFdqREVPc1hSZ1FnbzBPdXBOdlVFNXM1RGtzNHMyTHg4SzdKdHhXMGxyeXFqbFJZQWRYT3dSUApDbUN5Mk84V0hSVU8vNDAvTGNjWkhFc1NOaTBBSTUwZGRlWk0zSm1QSXRtOXBOQUkxdGZNZjU3Snk2aFVsbmVICnhZZnlrSVJob2ZWdFl2Z2xCQ1NSNTdBbVNFUHZHT0VMOUxpZXV4M0NFVTlWQk5lRGdSUTFweHdLK3IyUW5Bd0wKYmxuNzdCczZVWGM0dmtsZ2dSbHlMTm5ZdG01WUpMRXdqZDNuQzNLWFJoWXZnN3V0eDdLQ2xvZHpkSXVtVldpYgpyQ3BJdG9NPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRREoybnZ4TGl0OS9IOXQKMGh1K0d0d1p6Wkh5d2M1RkhpeFpyMkhhZFRpVG9EZUNjYnZtNjBDNVFyc3Z5d1BhR3lYc3FSNnF3ZnVRTmZkWgptVkg0dEZmc0NnK0N1ZzVxUjFTWE82UU90dEY5cWdKUFpheW1tRXJQekZ0SHBHNHk0MmV3NG15eVcvNDRBTzUxCnY0ZGYyeHZZcVBUbTdtOTBIUE1FSWZoa1phbEpvaE81cWhLd2taMzVNZ3VKUVIzZWxBaWZ2K2toUHozbkVZUHkKN3o3TTMxemJHQXp4Y0JxV3NZMm9GS3RJOWJDRXNyTnNjYndDT3V0WXdDQ0FsWTZCUC8ycm9uREF1eEgvZllYTApzMkNRdTFSK1dWZk1WM0QwdFpYNUtmRnNXOVJ5Tmoyeno1M29xTndpVFgzbW9ERFdqUzliVHdKdzJFSEt3Yk4wClNwVGxnVmRQQWdNQkFBRUNnZ0VBUDFpZ290ekJhMlZOUEZLK3dCYy8wWjB3MjBVMURYM2RuenVwOHR2c3FHK1UKWEF5RFVvR3JxemdrOUdlNnlyelFWd2Z3QnRpZnNPOHVzK0NvMStzSTJKdURxSnZwSUROSWVibU96OHRSelNVSQpXcEJtOFZWRHpSaXQ0THJhbG4vRkw3NnZLLzR3dHJTY0lUbTlLempnOFVwOHFPaFU4OVNOODFNUjE3Z0x1MzVoCnZSR1ZQcWdNS1o3YVdDMmpOeXpsY1BHU29CRTI3ZmJaMDJldWx2bnVIbTZQY1daYisxT1Zjc01BcHZMRU5TeHYKcXNFUDNYODFjMkJ1V0RPemJtNi90WTN6TTRoL0FMQWg4OXkwbHJCaFEyMmZuS3BxOTlXaGxPSkxBVDY1amdFbgpQNzhJeWdIcW9yNEkrbUpZeDV5WFA2cHhuN1hsYXpsUFcyZ1k4OUlyUVFLQmdRRFVTVzRpMHVyd2tqVGQ4VTJxCnlFb3hQUkIxc24rTythZmZRVlJKRTZ0S05saWZhaGx5V3NjOThwZmVlQklDMHhpT282VHNqSmVLQnhJajNVeXEKNkx6cFFzSnVsYnVJWUJPNWpSMVdIU2FPbllzSEdGWi9SWFRVSytkaEJZQzcwc3VQb1RWWWtXc1RacXcwbTBKeQpDeVo0OCtlUUh1Z29sbkxBcVNvdTNhRnc3d0tCZ1FEemF4Q0hxd0FHYW5MM05qRUZSTGIrdFR3SXVsZVdpbzl5CnB6U2xBaE1wVklTQk5VTyt4NW94S00zelBhalorQXQ2QzNoZnM4a29aMDFBVkhHdXprczNHOFR6a3V4SnBHY2oKZkliNVpONTVGTytWL2lBOW54Qnh6MmNKR0VmUDFkYlVjc3BjSVlYeHpOeG1zNlRuU1JtaEZDeUxEUE1QSzZMWQo1UCtidmJtL29RS0JnQng4UmZVU1RFZy90aXhaNXN3VjJDN0hQT0F1TllPZjZIREN1V2FjNXcwc1FiUVNicHV6CnBxeWZVdFdkVXYxaUNoZUp5ZVdiNy9HcmhUbWV4bHpnb2dqQzFvZzBPMWZQWEpZM1kwcGMyd0drRGpYRGhFZkwKc0NPUVNKbnlQUlgyOFMyeXVnL0tZNDNVNXlLZitzaUd5b0RNYWJRakVZL3dzREUrQWRVTUZFK3RBb0dBR0lzagpENHJlWmNjMThGYzJlaUdEa2dzVUVvMDNaNlp3OEU2THNGZVZOd1dlbHFpWVBCUkVKOURGYzFFMFJVWU5ZakRsCjRrQnVkL1J5aFpuK0hISVFnMjM1WGRYaW5VcEdXLzJpWG1NZFMzZ2c4QzYvY1hjb1lWRllRa0tBZXlSRWxRYysKQUN3aEpWQlNxTWhVU0QzR3A4Y3c5cFJIcmEvb3E1WHJiL2loVWdFQ2dZRUFqNmNwYkhDUzkyQnA0cG8wNHI5Zgp6WHNrak5rR3hVbUw3Z1NHYmpoNTBLUGloSzY5ZElqcUlCRzN4TklaeW9vWmJqbE5DV2NsL29LcDhlSHN5TlNjCm5SUlJrVFdwMTJyVDhvVGRSckZCcDJiNTdUblB3NXV1NEswVDMrelJKY3RnNkhMK2h0K0xrc29nWkRwTXpUcFUKL2QwdHBCc0N1V0tiUkdRcGlRcU90ZEU9Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K
type: kubernetes.io/tls

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: cfgmap-site
data:
  index.html:  |
    <html>
    It's working!
    </html>

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
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
        volumeMounts:
        - name: cfgm-vol
          mountPath: /usr/share/nginx/html/index.html
          subPath: index.html
      volumes:
      - name: cfgm-vol
        configMap:
          name: cfgmap-site

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
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-mt-ingress
spec:
  rules:
  - host: qqq.local
    http:
      paths:
      - path: /
        pathType: Exact
        backend:
          service:
            name: nginx-service
            port:
              number: 9001
  tls:
    - hosts:
      - qqq.local
      secretName: scr-tls
```

### Результат
![img.png](img.png)