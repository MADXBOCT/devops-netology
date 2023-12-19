## Задание 1

### Часть 1,2.

#### Манифест PV,PVC, deployment
```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv-1
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  local:
    path: /tmp/qqq
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - srvlandevops2

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc-vol
spec:
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mt-bb
#  namespace: default
  labels:
    app.kubernetes.io/name: mt-bb
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: mt-bb
  template:
    metadata:
      labels:
        app.kubernetes.io/name: mt-bb
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        volumeMounts:
        - name: shvol1
          mountPath: /out
      - name: busybox
        image: busybox
        command: ['sh', '-c', 'while true; do echo "it-s working" >> /in/file.txt; sleep 5; done']
        volumeMounts:
        - name: shvol1
          mountPath: /in
      volumes:
        - name: shvol1
#          emptyDir: {}
          persistentVolumeClaim:
            claimName: my-pvc-vol
```
Результат
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl get po,pv,pvc,deployments.apps
NAME                         READY   STATUS    RESTARTS   AGE
pod/mt-bb-6f8d46f9bf-llhkf   2/2     Running   0          5m16s

NAME                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                STORAGECLASS   REASON   AGE
persistentvolume/my-pv-1   1Gi        RWO            Retain           Bound    default/my-pvc-vol                           5m16s

NAME                               STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/my-pvc-vol   Bound    my-pv-1   1Gi        RWO                           5m16s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mt-bb   1/1     1            1           5m16s
ubuntu@srvlandevops2:~/kuber$
```

### Часть 3.

Заходим в созданный под в контейнер multitool, ставим метки из даты, считаем кол-во строк в файле - оно должно увеличиваться
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl exec -it mt-bb-6f8d46f9bf-llhkf -c multitool -- bash
mt-bb-6f8d46f9bf-llhkf:/# date
Tue Dec 19 18:52:49 UTC 2023
mt-bb-6f8d46f9bf-llhkf:/# wc -l /out/file.txt
110 /out/file.txt
mt-bb-6f8d46f9bf-llhkf:/# date
Tue Dec 19 18:53:06 UTC 2023
mt-bb-6f8d46f9bf-llhkf:/# wc -l /out/file.txt
112 /out/file.txt
mt-bb-6f8d46f9bf-llhkf:/#
```

### Часть 4.

Удаляем Deployment, PVC
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl delete deployments.apps mt-bb
deployment.apps "mt-bb" deleted
ubuntu@srvlandevops2:~/kuber$ kubectl delete pvc my-pvc-vol
persistentvolumeclaim "my-pvc-vol" deleted
```
Смотрим, что с PV
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl get po,pv,pvc,deployments.apps
NAME                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                STORAGECLASS   REASON   AGE
persistentvolume/my-pv-1   1Gi        RWO            Retain           Released   default/my-pvc-vol                           14m
ubuntu@srvlandevops2:~/kuber$
```
PV остался благодаря `RECLAIM POLICY = Retain` \
В документации четко об этом [сказано](https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/)
> With the "Retain" policy, if a user deletes a PersistentVolumeClaim, the corresponding PersistentVolume will not be deleted. Instead, it is moved to the Released phase, where all of its data can be manually recovered.

### Часть 5. 
Файл на месте
```bash
ubuntu@srvlandevops2:~/kuber$ ls /tmp/qqq
file.txt
```
Удаляем PV
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl delete pv my-pv-1
persistentvolume "my-pv-1" deleted
ubuntu@srvlandevops2:~/kuber$ ls /tmp/qqq
file.txt
```
Файл остался на локальном диске ноды, так как использовался тип PV=local
В документации и про это [написано](https://kubernetes.io/docs/concepts/storage/volumes/#local)
> Note: The local PersistentVolume requires manual cleanup and deletion by the user if the external static provisioner is not used to manage the volume lifecycle.

