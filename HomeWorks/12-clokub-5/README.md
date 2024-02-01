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

ubuntu@kubnode1:~/kuber$ kubectl logs pods/web-consumer-5f87765478-4fdcc -n web
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
```
