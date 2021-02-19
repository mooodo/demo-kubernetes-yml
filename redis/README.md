# 在Kubernetes中安装redis
这是一个演示在Kubernetes中安装部署redis
## 单机部署redis
执行命令脚本：

```bash
kubectl create -f redis.yaml
```
部署成功后，可以通过redis-0.redis进行k8s集群内部各微服务的访问。

## 集群部署redis
### 1.创建redis客户端
执行命令创建docker镜像，并上传本地私服：

```bash
docker build -t redis-tools ./redis-tools/.
docker tag redis-tools 172.31.87.111:5000/redis-tools
docker push 172.31.87.111:5000/redis-tools
```
该客户端安装了redis集群安装所需的redis-trib工具

### 2.k8s集群部署
执行命令脚本：

```bash
cd redis-cluster
kubectl create -f .
```
执行成功后，在k8s部署了3个redis主节点，并分别为它们部署了从节点
### 3.验证redis集群部署
进入redis集群中的任意节点的客户端，执行：

```
redis-cli
```
检查redis集群状态：

```
> cluster nodes
```
有3个master主节点，并且每一个master主节点都连接了一个对应的slave从节点，那么搭建就成功了
### 4.连接redis集群
应用程序或微服务要使用redis集群，需要修改配置文件：

```
    # host: redis-0.redis
    # port: 6379
    cluster:
      nodes: redis-cluster-0.redis-cluster:6379,redis-cluster-1.redis-cluster:6379,redis-cluster-2.redis-cluster:6379
```
如果采用微服务架构，可以将以上配置放到config服务器中进行集中式配置，便于日后维护