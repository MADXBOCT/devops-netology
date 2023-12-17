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
      - name: busybox
        image: busybox
        command: ['sh', '-c', 'while true; do echo "it-s working" >> /in/file.txt; sleep 5; done']
```