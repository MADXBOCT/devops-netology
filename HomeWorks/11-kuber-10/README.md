## Задание 1
### Манифест deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mt-bb
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
        command: ['sh', '-c', 'while true; do echo "it-s working" >> /in/file.txt; sleep 2; done']
        volumeMounts:
        - name: shvol1
          mountPath: /in
      volumes:
        - name: shvol1
          emptyDir: {}
```

Провекрка, что deployment прошел
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl get po
NAME                   READY   STATUS    RESTARTS   AGE
mt-bb-f5584757-brcn4   2/2     Running   0          5m1s
```

Заходим в созданный под в контейнер multitool \
`ubuntu@srvlandevops2:~/kuber$ kubectl exec -it mt-bb-f5584757-brcn4 -c multitool -- bash`

Проверяем что директории `/in` нет, а `/out` есть; ставим метки из даты, считаем кол-во строк в файле - оно должно увеличиваться
```bash
mt-bb-f5584757-brcn4:/# ls /in
ls: /in: No such file or directory
mt-bb-f5584757-brcn4:/# ls /out
file.txt
mt-bb-f5584757-brcn4:/# date
Sat Nov 11 12:53:18 UTC 2023
mt-bb-f5584757-brcn4:/# cat /out/file.txt | wc -l
197
mt-bb-f5584757-brcn4:/# date
Sat Nov 11 12:53:34 UTC 2023
mt-bb-f5584757-brcn4:/# cat /out/file.txt | wc -l
200
mt-bb-f5584757-brcn4:/#
```

## Задание 2
### Манифест deployment

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: multitool-ds
#  namespace: kube-system
  labels:
    k8s-app: multitool-ds
spec:
  selector:
    matchLabels:
      name: multitool-ds
  template:
    metadata:
      labels:
        name: multitool-ds
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

Проверяем, что Daemonset поднял под, заходим в него и открываем лог\
```bash
ubuntu@srvlandevops2:~/kuber$ kubectl get po
NAME                   READY   STATUS    RESTARTS   AGE
mt-bb-f5584757-brcn4   2/2     Running   0          39m
multitool-ds-krhjw     1/1     Running   0          10s
ubuntu@srvlandevops2:~/kuber$ kubectl exec -it multitool-ds-krhjw -- bash
multitool-ds-krhjw:/# cd /var/log
multitool-ds-krhjw:/var/log# tail -F ./syslog
Nov 11 13:26:07 srvlandevops2 microk8s.daemon-containerd[1473354]: time="2023-11-11T13:26:07.734537742Z" level=info msg="PullImage \"wbitt/network-multitool:latest\" returns image reference \"sha256:713337546be623588ed8ffd6d5e15dd3ccde8e4555ac5c97e5715d03580d2824\""
Nov 11 13:26:07 srvlandevops2 microk8s.daemon-containerd[1473354]: time="2023-11-11T13:26:07.737836152Z" level=info msg="CreateContainer within sandbox \"a02413f29e36bc5e2d1494b52c9ba1d8b8ce46027c8914a21bcdb7640e111aa5\" for container &ContainerMetadata{Name:multitool,Attempt:0,}"
Nov 11 13:26:07 srvlandevops2 microk8s.daemon-containerd[1473354]: time="2023-11-11T13:26:07.751454318Z" level=info msg="CreateContainer within sandbox \"a02413f29e36bc5e2d1494b52c9ba1d8b8ce46027c8914a21bcdb7640e111aa5\" for &ContainerMetadata{Name:multitool,Attempt:0,} returns container id \"8f2182a0dd1507047862c34cd2bded46fa9fc10eda68f168c437c4c54aeab7fe\""
Nov 11 13:26:07 srvlandevops2 microk8s.daemon-containerd[1473354]: time="2023-11-11T13:26:07.752151442Z" level=info msg="StartContainer for \"8f2182a0dd1507047862c34cd2bded46fa9fc10eda68f168c437c4c54aeab7fe\""
Nov 11 13:26:07 srvlandevops2 systemd[1]: var-snap-microk8s-common-var-lib-containerd-tmpmounts-containerd\x2dmount1220618587.mount: Deactivated successfully.
Nov 11 13:26:07 srvlandevops2 microk8s.daemon-containerd[1473354]: time="2023-11-11T13:26:07.835699411Z" level=info msg="StartContainer for \"8f2182a0dd1507047862c34cd2bded46fa9fc10eda68f168c437c4c54aeab7fe\" returns successfully"
Nov 11 13:26:08 srvlandevops2 microk8s.daemon-kubelite[1473551]: I1111 13:26:08.308515 1473551 pod_startup_latency_tracker.go:102] "Observed pod startup duration" pod="default/multitool-ds-krhjw" podStartSLOduration=-9.223372033546324e+09 pod.CreationTimestamp="2023-11-11 13:26:05 +0000 UTC" firstStartedPulling="2023-11-11 13:26:06.630353565 +0000 UTC m=+837657.141213126" lastFinishedPulling="0001-01-01 00:00:00 +0000 UTC" observedRunningTime="2023-11-11 13:26:08.307574563 +0000 UTC m=+837658.818434147" watchObservedRunningTime="2023-11-11 13:26:08.308451128 +0000 UTC m=+837658.819310694"
Nov 11 13:26:18 srvlandevops2 systemd[1]: run-containerd-runc-k8s.io-1b92e261407b7f1d69bbe40e201a919680b3cf1d502c2769b0e471c966181cee-runc.X4awJ4.mount: Deactivated successfully.
Nov 11 13:26:19 srvlandevops2 systemd[1]: run-containerd-runc-k8s.io-7305fd0984e2142b84555414703d1bae6d44999b6f04a799d512a398f777448d-runc.fPSSzc.mount: Deactivated successfully.
Nov 11 13:26:38 srvlandevops2 systemd[1]: run-containerd-runc-k8s.io-1b92e261407b7f1d69bbe40e201a919680b3cf1d502c2769b0e471c966181cee-runc.Q1UWKV.mount: Deactivated successfully.
```