Проверим, что приложения запустились
```bash
ubuntu@kubnode1:~/kuber$ kubectl get all -n web
NAME                                READY   STATUS    RESTARTS   AGE
pod/web-consumer-5f87765478-4fdcc   1/1     Running   0          64s
pod/web-consumer-5f87765478-bnx5v   1/1     Running   0          65s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web-consumer   2/2     2            2           65s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/web-consumer-5f87765478   2         2         2       65s
ubuntu@kubnode1:~/kuber$ kubectl get all -n data
NAME                           READY   STATUS    RESTARTS   AGE
pod/auth-db-7b5cdbdc77-mhxx9   1/1     Running   0          72s

NAME              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/auth-db   ClusterIP   10.97.224.55   <none>        80/TCP    72s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/auth-db   1/1     1            1           72s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/auth-db-7b5cdbdc77   1         1         1       72s
```

Посмотрим лог пода web
```bash
ubuntu@kubnode1:~/kuber$ kubectl logs pods/web-consumer-5f87765478-4fdcc -n web
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
```

Под не может разрезолвить имя сервиса в DNS.\
Проверим конфиг dns-клиента в поде.
```bash
ubuntu@kubnode1:~/kuber$ kubectl -n web exec web-consumer-5f87765478-kjxpx -- cat /etc/resolv.conf
search web.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5
```
IP nameserver'а приехал, так же приехали dns суффиксы 

Изучение документации [Debugging DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/), [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#what-things-get-dns-names) и анализ показывает, что под не может резолвить, так как находится в другом namespace

Варианты решения:
- Поместить все поды в единый namespace
- Вызывать команду в формате `<service-name>.<namespace>`

Проверка по варинту 2:
```bash
ubuntu@kubnode1:~/kuber$ kubectl -n web exec web-consumer-5f87765478-kjxpx -- curl auth-db.data
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
100   612  100   612    0     0   7259      0 --:--:-- --:--:-- --:--:--  7746
```