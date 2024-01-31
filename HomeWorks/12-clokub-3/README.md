### Подготовка

Кластер k8s с сетевым плагином Calico были развернты в [предыдущей домашке](https://github.com/MADXBOCT/devops-netology/tree/main/HomeWorks/12-clokub-2#kubnode1-master)


### Манифест

Namespace, Деплойменты, сервисы, сетевые правила

```yaml
kind: Namespace
apiVersion: v1
metadata:
  name: app
  labels:
    name: app

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: app
  labels:
    app.kubernetes.io/name: multitool-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: multitool-frontend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: multitool-frontend
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        ports:
        - containerPort: 8081
          name: multitool-8081
        env:
          - name: HTTP_PORT
            value: "8081"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: app
  labels:
    app.kubernetes.io/name: multitool-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: multitool-backend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: multitool-backend
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        ports:
        - containerPort: 8082
          name: multitool-8082
        env:
          - name: HTTP_PORT
            value: "8082"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cache
  namespace: app
  labels:
    app.kubernetes.io/name: multitool-cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: multitool-cache
  template:
    metadata:
      labels:
        app.kubernetes.io/name: multitool-cache
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        ports:
        - containerPort: 8083
          name: multitool-8083
        env:
          - name: HTTP_PORT
            value: "8083"

---
apiVersion: v1
kind: Service
metadata:
  name: multitool-service-frontend
  namespace: app
spec:
  selector:
    app.kubernetes.io/name: multitool-frontend
  ports:
    - name: http-multitool-port-frontend
      protocol: TCP
      port: 9001
      targetPort: multitool-8081

---
apiVersion: v1
kind: Service
metadata:
  name: multitool-service-backend
  namespace: app
spec:
  selector:
    app.kubernetes.io/name: multitool-backend
  ports:
    - name: http-multitool-port-backend
      protocol: TCP
      port: 9002
      targetPort: multitool-8082

---
apiVersion: v1
kind: Service
metadata:
  name: multitool-service-cache
  namespace: app
spec:
  selector:
    app.kubernetes.io/name: multitool-cache
  ports:
    - name: http-multitool-port-cache
      protocol: TCP
      port: 9003
      targetPort: multitool-8083

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: app
spec:
  podSelector: {}
  policyTypes:
    - Ingress

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-to-cache
  namespace: app
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: multitool-cache
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: multitool-backend
      ports:
        - port: 8083

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-backend
  namespace: app
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: multitool-backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: multitool-frontend
      ports:
        - port: 8082
```

### Результаты

Из пода backend нет доступа в frontend
```bash
ubuntu@kubnode1:~/kuber$ kubectl -n app exec backend-56574fc58b-5pxrs -- curl multitool-service-frontend:9001
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0^C
```

Есть доступ из пода backend в cache

```bash
ubuntu@kubnode1:~/kuber$ kubectl -n app exec backend-56574fc58b-5pxrs -- curl multitool-service-cache:9003
WBITT Network MultiTool (with NGINX) - cache-6678686469-bqv9m - 10.244.128.89 - HTTP: 8083 , HTTPS: 443 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   142  100   142    0     0  27192      0 --:--:-- --:--:-- --:--:-- 28400
```

и из пода frontend в backend

```bash
ubuntu@kubnode1:~/kuber$ kubectl -n app exec frontend-5b87755f4f-wbff8 -- curl multitool-service-backend:9002
WBITT Network MultiTool (with NGINX) - backend-56574fc58b-5pxrs - 10.244.61.83 - HTTP: 8082 , HTTPS: 443 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   143  100   143    0     0   2926      0 --:--:-- --:--:-- --:--:--  3042
ubuntu@kubnode1:~/kuber$
```