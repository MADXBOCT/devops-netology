## Задание 1

Исходя из условий задания:
 - нет свободных ресурсов - развернуть еще одну копию невозможно значит canary, blue-grenn a/b отпадают
 - версии несовместимы - нужно быстро заменить весь комплект подов \
я бы выбрал
 - если нужно сохранить доступность приложени - rollout с параметром `maxSurge: 20%` в момент минимальной нагрузки
 - если доступность неважна Recreate

## Задание 2

### Манифест

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  namespace: app
  labels:
    app.kubernetes.io/name: nginx-multitool
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 100%
      maxUnavailable: 80%
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
        image: nginx:1.19
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

```

### 2.1 Результат

```bash
ubuntu@kubnode1:~/kuber$ kubectl describe deployments.apps/my-deployment -n app
Name:                   my-deployment
Namespace:              app
CreationTimestamp:      Thu, 01 Feb 2024 11:19:31 +0000
Labels:                 app.kubernetes.io/name=nginx-multitool
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app.kubernetes.io/name=nginx-multitool
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  80% max unavailable, 100% max surge
Pod Template:
  Labels:  app.kubernetes.io/name=nginx-multitool
  Containers:
   nginx:
    Image:        nginx:1.19
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
   multitool:
    Image:      wbitt/network-multitool
    Port:       8080/TCP
    Host Port:  0/TCP
    Environment:
      HTTP_PORT:  8080
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   my-deployment-6d8794db95 (5/5 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  62s   deployment-controller  Scaled up replica set my-deployment-6d8794db95 to 5
```
### 2.2 Обновляем nginx 1.20
```bash 
ubuntu@kubnode1:~/kuber$ kubectl set image deployment.apps/my-deployment nginx=nginx:1.20 -n app
deployment.apps/my-deployment image updated
ubuntu@kubnode1:~/kuber$ kubectl rollout status deployment.apps/my-deployment -n app
deployment "my-deployment" successfully rolled out
ubuntu@kubnode1:~/kuber$ kubectl describe deployments.apps/my-deployment -n app
Name:                   my-deployment
Namespace:              app
CreationTimestamp:      Thu, 01 Feb 2024 11:19:31 +0000
Labels:                 app.kubernetes.io/name=nginx-multitool
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app.kubernetes.io/name=nginx-multitool
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  80% max unavailable, 100% max surge
Pod Template:
  Labels:  app.kubernetes.io/name=nginx-multitool
  Containers:
   nginx:
    Image:        nginx:1.20
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
   multitool:
    Image:      wbitt/network-multitool
    Port:       8080/TCP
    Host Port:  0/TCP
    Environment:
      HTTP_PORT:  8080
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  my-deployment-6d8794db95 (0/0 replicas created)
NewReplicaSet:   my-deployment-6f5485b6c (5/5 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  3m35s  deployment-controller  Scaled up replica set my-deployment-6d8794db95 to 5
  Normal  ScalingReplicaSet  21s    deployment-controller  Scaled up replica set my-deployment-6f5485b6c to 5
  Normal  ScalingReplicaSet  21s    deployment-controller  Scaled down replica set my-deployment-6d8794db95 to 1 from 5
  Normal  ScalingReplicaSet  19s    deployment-controller  Scaled down replica set my-deployment-6d8794db95 to 0 from 1
```

### 2.3 Обновляем nginx 1.28 (неудачно, но 1 под доступен)
```bash 
ubuntu@kubnode1:~/kuber$ kubectl set image deployment.apps/my-deployment nginx=nginx:1.28 -n app
deployment.apps/my-deployment image updated
ubuntu@kubnode1:~/kuber$ kubectl rollout status deployment.apps/my-deployment -n app
Waiting for deployment "my-deployment" rollout to finish: 1 old replicas are pending termination...
^Cubuntu@kubnode1:~/kuber$ kubectdescribe deployments.apps/my-deploymentnt -n app
Name:                   my-deployment
Namespace:              app
CreationTimestamp:      Thu, 01 Feb 2024 11:19:31 +0000
Labels:                 app.kubernetes.io/name=nginx-multitool
Annotations:            deployment.kubernetes.io/revision: 3
Selector:               app.kubernetes.io/name=nginx-multitool
Replicas:               5 desired | 5 updated | 6 total | 1 available | 5 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  80% max unavailable, 100% max surge
Pod Template:
  Labels:  app.kubernetes.io/name=nginx-multitool
  Containers:
   nginx:
    Image:        nginx:1.28
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
   multitool:
    Image:      wbitt/network-multitool
    Port:       8080/TCP
    Host Port:  0/TCP
    Environment:
      HTTP_PORT:  8080
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    ReplicaSetUpdated
OldReplicaSets:  my-deployment-6d8794db95 (0/0 replicas created), my-deployment-6f5485b6c (1/1 replicas created)
NewReplicaSet:   my-deployment-7bd4b9cbff (5/5 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  6m40s  deployment-controller  Scaled up replica set my-deployment-6d8794db95 to 5
  Normal  ScalingReplicaSet  3m26s  deployment-controller  Scaled up replica set my-deployment-6f5485b6c to 5
  Normal  ScalingReplicaSet  3m26s  deployment-controller  Scaled down replica set my-deployment-6d8794db95 to 1 from 5
  Normal  ScalingReplicaSet  3m24s  deployment-controller  Scaled down replica set my-deployment-6d8794db95 to 0 from 1
  Normal  ScalingReplicaSet  33s    deployment-controller  Scaled up replica set my-deployment-7bd4b9cbff to 5
  Normal  ScalingReplicaSet  33s    deployment-controller  Scaled down replica set my-deployment-6f5485b6c to 1 from 5
```

### 2.4 Откат

```bash
ubuntu@kubnode1:~/kuber$ kubectl rollout undo deployment my-deployment -n app
deployment.apps/my-deployment rolled back
ubuntu@kubnode1:~/kuber$
ubuntu@kubnode1:~/kuber$
ubuntu@kubnode1:~/kuber$ kubectl describe deployments.apps/my-deployment -n app
Name:                   my-deployment
Namespace:              app
CreationTimestamp:      Thu, 01 Feb 2024 11:19:31 +0000
Labels:                 app.kubernetes.io/name=nginx-multitool
Annotations:            deployment.kubernetes.io/revision: 4
Selector:               app.kubernetes.io/name=nginx-multitool
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  80% max unavailable, 100% max surge
Pod Template:
  Labels:  app.kubernetes.io/name=nginx-multitool
  Containers:
   nginx:
    Image:        nginx:1.20
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
   multitool:
    Image:      wbitt/network-multitool
    Port:       8080/TCP
    Host Port:  0/TCP
    Environment:
      HTTP_PORT:  8080
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  my-deployment-6d8794db95 (0/0 replicas created), my-deployment-7bd4b9cbff (0/0 replicas created)
NewReplicaSet:   my-deployment-6f5485b6c (5/5 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  8m50s  deployment-controller  Scaled up replica set my-deployment-6d8794db95 to 5
  Normal  ScalingReplicaSet  5m36s  deployment-controller  Scaled up replica set my-deployment-6f5485b6c to 5
  Normal  ScalingReplicaSet  5m36s  deployment-controller  Scaled down replica set my-deployment-6d8794db95 to 1 from 5
  Normal  ScalingReplicaSet  5m34s  deployment-controller  Scaled down replica set my-deployment-6d8794db95 to 0 from 1
  Normal  ScalingReplicaSet  2m43s  deployment-controller  Scaled up replica set my-deployment-7bd4b9cbff to 5
  Normal  ScalingReplicaSet  2m43s  deployment-controller  Scaled down replica set my-deployment-6f5485b6c to 1 from 5
  Normal  ScalingReplicaSet  6s     deployment-controller  Scaled up replica set my-deployment-6f5485b6c to 5 from 1
  Normal  ScalingReplicaSet  6s     deployment-controller  Scaled down replica set my-deployment-7bd4b9cbff to 0 from 5
ubuntu@kubnode1:~/kuber$
```