# 路由监控zipkin
这是一个微服务的路由监控工具zipkin，它通过跟踪每一次用户请求在微服务间的调用过程，以及执行时长，来帮助优化微服务的路由。  
## 安装zipkin
### 1.安装mysql数据库
* 在mysql数据库中创建名为zipkin的数据库
* 创建zipkin用户，并授权。  
* 在mysql中执行zipkin.sql创建表

### 2.安装rabbitmq
详见“安装rabbitmq”部分

### 3.部署zipkin
执行脚本：

```bash
kubectl create -f zipkin.yaml
```