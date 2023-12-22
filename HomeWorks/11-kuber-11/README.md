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
Файл остался на локальном диске ноды, так как использовался тип `PV = local`. \
В документации и про это [написано](https://kubernetes.io/docs/concepts/storage/volumes/#local) 
> Note: The local PersistentVolume requires manual cleanup and deletion by the user if the external static provisioner is not used to manage the volume lifecycle.

## Задание 2
Установка nfs \
`sudo apt install -y nfs-common` \
`microk8s enable community` \
`microk8s enable nfs`

Автоматически создается storage class
```bash
ubuntu@srvlandevops2:~$ kubectl describe sc
Name:                  nfs
IsDefaultClass:        No
Annotations:           meta.helm.sh/release-name=nfs-server-provisioner,meta.helm.sh/release-namespace=nfs-server-provisioner
Provisioner:           cluster.local/nfs-server-provisioner
Parameters:            <none>
AllowVolumeExpansion:  True
MountOptions:
  vers=3
ReclaimPolicy:      Delete
VolumeBindingMode:  Immediate
Events:             <none>
```

Манифест
```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs
  labels:
    vol: pvc-nfs
spec:
  storageClassName: "nfs"
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mt
  labels:
    app.kubernetes.io/name: mt
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: mt
  template:
    metadata:
      labels:
        app.kubernetes.io/name: mt
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        volumeMounts:
        - name: vol1
          mountPath: /out
      volumes:
        - name: vol1
          persistentVolumeClaim:
            claimName: pvc-nfs
```

Заходим в под и создаем пустой файл, выходим, вносим изменения, снова заходим, проверяем.
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl -it exec mt-58bdb479fc-l9m7k -- bash
mt-58bdb479fc-l9m7k:/# cd /out
mt-58bdb479fc-l9m7k:/out# touch file.txt
mt-58bdb479fc-l9m7k:/out# exit
exit
ubuntu@srvlandevops2:~/kuber$ cd /var/snap/microk8s/common/nfs-storage
ubuntu@srvlandevops2:/var/snap/microk8s/common/nfs-storage$ ll
total 36
drwxr-xr-x 5 root root 4096 Dec 22 15:01 ./
drwxr-xr-x 8 root root 4096 Dec 22 14:59 ../
-rw-r--r-- 1 root root 4736 Dec 22 15:00 ganesha.log
-rw------- 1 root root   36 Dec 22 14:59 nfs-provisioner.identity
drwxrwsrwx 2 root root 4096 Dec 22 15:46 pvc-4b29d08d-9dc0-40a3-87d4-1ad669d96ac4/
drwxr-xr-x 3 root root 4096 Dec 22 14:59 v4old/
drwxr-xr-x 3 root root 4096 Dec 22 14:59 v4recov/
-rw------- 1 root root  921 Dec 22 15:01 vfs.conf
ubuntu@srvlandevops2:/var/snap/microk8s/common/nfs-storage$ cd pvc-4b29d08d-9dc0-40a3-87d4-1ad669d96ac4/
ubuntu@srvlandevops2:/var/snap/microk8s/common/nfs-storage/pvc-4b29d08d-9dc0-40a3-87d4-1ad669d96ac4$ ll
total 8
drwxrwsrwx 2 root root 4096 Dec 22 15:46 ./
drwxr-xr-x 5 root root 4096 Dec 22 15:01 ../
-rw-r--r-- 1 root root    0 Dec 22 15:46 file.txt
ubuntu@srvlandevops2:/var/snap/microk8s/common/nfs-storage/pvc-4b29d08d-9dc0-40a3-87d4-1ad669d96ac4$ sudo nano file.txt
ubuntu@srvlandevops2:/var/snap/microk8s/common/nfs-storage/pvc-4b29d08d-9dc0-40a3-87d4-1ad669d96ac4$ kubectl -it exec mt-58bdb479fc-l9m7k -- bash
mt-58bdb479fc-l9m7k:/# cat /out/file.txt
11111
mt-58bdb479fc-l9m7k:/#
```