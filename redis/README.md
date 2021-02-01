# 在Kubernetes中安装redis
这是一个演示在Kubernetes中安装部署redis
## 单机部署redis
执行命令脚本：

```bash
kubectl create -f redis.yaml
```
部署成功后，可以通过redis-0.redis进行k8s集群内部各微服务的访问。

## 集群部署redis
### 1.k8s集群部署
执行命令脚本：

```bash
kubectl create -f redis-cluster.yaml
```
执行成功后，在k8s部署了6个节点的redis，但它们还未建立集群。
### 2.创建redis客户端
执行命令创建docker镜像，并上传本地私服：

```bash
docker build -t redis-tools ./redis-tools/.
docker tag redis-tools 172.31.87.111:5000/redis-tools
docker push 172.31.87.111:5000/redis-tools
```
执行k8s命令：

```bash
kubectl run redis-tools --image=172.31.87.111:5000/redis-tools -it --restart=Never
```
在redis-tools中执行命令，创建redis主节点集群：

```
redis-trib.py create \
  `dig +short redis-cluster-0.redis-cluster.default.svc.cluster.local`:6379 \
  `dig +short redis-cluster-1.redis-cluster.default.svc.cluster.local`:6379 \
  `dig +short redis-cluster-2.redis-cluster.default.svc.cluster.local`:6379
```
为每个redis主节点配置从节点：

```
redis-trib.py replicate \
  --master-addr `dig +short redis-cluster-0.redis-cluster.default.svc.cluster.local`:6379 \
  --slave-addr `dig +short redis-cluster-3.redis-cluster.default.svc.cluster.local`:6379

redis-trib.py replicate \
  --master-addr `dig +short redis-cluster-1.redis-cluster.default.svc.cluster.local`:6379 \
  --slave-addr `dig +short redis-cluster-4.redis-cluster.default.svc.cluster.local`:6379

redis-trib.py replicate \
  --master-addr `dig +short redis-cluster-2.redis-cluster.default.svc.cluster.local`:6379 \
  --slave-addr `dig +short redis-cluster-5.redis-cluster.default.svc.cluster.local`:6379
```
进入redis集群中的某个节点的客户端：

```
redis-cli -h `dig +short redis-cluster-0.redis-cluster.default.svc.cluster.local`
```
检查redis集群状态：

```
> cluster nodes
```
每一个master主节点都连接了一个对应的slave从节点，那么搭建就成功了