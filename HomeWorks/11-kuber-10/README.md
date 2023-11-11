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

Заходим в созданный под в контейнер multitool
`ubuntu@srvlandevops2:~/kuber$ kubectl exec -it mt-bb-f5584757-brcn4 -c multitool -- bash`

Проверяем что директории /in нет, а out есть; ставим метки из даты, считаем кол-во строк в файле - оно должно увеличиваться
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