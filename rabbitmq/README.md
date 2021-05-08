# 在Kubernetes中安装rabbitmq
这是一个演示在Kubernetes中安装部署rabbitmq
## 单机部署rabbitmq
执行命令：

```bash
kubectl create -f rabbitmq.yaml
```
部署成功后，可以通过rabbitmq-0.rabbit进行k8s集群内部各微服务的访问。

## 集群部署rabbitmq
### 1.创建cookie

```bash
echo $(openssl rand -base64 32) > erlang.cookie
kubectl create secret generic erlang.cookie --from-file=erlang.cookie
```

### 2.分布式部署rabbitmq集群

```bash
cd rabbit-cluster
kubectl apply -f .
```

### 3.完成集群配置
用以下命令分别进入除rabbit-cluster-0以外的每一个节点：

```bash
kubectl exec -it -n r rabbitmq-1 /bin/bash
```
在每一个节点中完成以下集群配置：

```bash
rabbitmqctl --erlang-cookie $(cat $HOME/.erlang.cookie) stop_app
rabbitmqctl --erlang-cookie $(cat $HOME/.erlang.cookie) join_cluster rabbit@rabbitmq-0
rabbitmqctl --erlang-cookie $(cat $HOME/.erlang.cookie) start_app
```

### 4.检查集群部署
访问http://ip:30671访问rabbitmq控制台

