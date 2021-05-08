# Kubernetes日志监控EFK
这是Kubernetes日志监控EFK的安装脚本，在部署时执行：

```bash
kubectl delete -f .
kubectl create -f .
```

如果希望在kibana中使用组件logtrail，重新制作kibana镜像：

```bash
cd kibana
docker build -t kibana .
```
制作好以后，将kibana-deployment.yaml中的镜像改为该镜像：

```
...
    spec:
      containers:
      - name: kibana-logging
        image: kibana #kibana:7.2.0
        resources:
...
```