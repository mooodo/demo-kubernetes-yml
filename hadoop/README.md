# 在Kubernetes中安装部署hadoop
这是一个演示在Kubernetes中安装部署hadoop, hive, spark
## 准备工作
1.下载hadoop  

```bash
wget http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
```
2.下载hive  

```bash
wget http://mirror.bit.edu.cn/apache/hive-2.3.7/apache-hive-2.3.7-bin.tar.gz
```
3.下载spark  

```bash
wget http://mirror.bit.edu.cn/apache/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz
```
## 制作镜像
执行命令制作Docker镜像，并上传本地私服：

```bash
docker build -t hadoop-spark
docker tag hadoop-spark 172.31.87.111:5000/hadoop-spark
docker push 172.31.87.111:5000/hadoop-spark
```
注意：172.31.87.111:5000是本地私服地址:端口号
## Kubernetes安装部署
1.安装mysql

```bash
kubectl create -f mysql.yaml
```
2.安装hadoop

```bash
kubectl create -f hadoop-hive.yaml
```
## 初始化hive数据库
### 第一次启动时，进入master节点：  
1.查找master节点的名称：

```bash
kubectl get po -n bigdata
```
2.进入master节点的操作系统：

```bash
kubectl exec -it hadoop-master-xxxxxx-xxxxx bash
```

### 进入master节点后，执行以下命令：

```bash
schematool -dbType mysql -initSchema
```