# 在Kubernetes中安装部署hadoop
这是一个演示在Kubernetes中安装部署hadoop, hive, spark等组件
## 安装hadoop, hive组件
1.下载hadoop  

```bash
cd hive
wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
```
2.下载hive  

```bash
wget https://mirrors.tuna.tsinghua.edu.cn/apache/hive-2.3.7/apache-hive-2.3.7-bin.tar.gz
```

3.其它
<p>下载jdk8：jdk-8u212-linux-x64.tar.gz
<p>下载mysql驱动：mysql-connector-java-8.0.15.jar
<p>4.制作hadoop-hive镜像
<p>执行命令制作Docker镜像：

```bash
docker build -t hadoop-hive .
```
## 安装sqoop, spark组件
1.下载sqoop  

```bash
cd ../spark
wget https://mirrors.tuna.tsinghua.edu.cn/apache/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
```

2.下载spark  

```bash
wget https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz
```
3.制作hadoop-sqoop-spark镜像
<p>执行命令制作Docker镜像：

```bash
docker build -t hadoop-sqoop-spark .
```
## 安装hbase, kylin组件
1.下载zookeeper

```bash
cd ../hbase
wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.5.9/apache-zookeeper-3.5.9-bin.tar.gz
```
2.下载hbase

```bash
wget https://mirrors.tuna.tsinghua.edu.cn/apache/hbase/1.6.0/hbase-1.6.0-bin.tar.gz
```
3.下载kylin

```bash
wget https://mirrors.tuna.tsinghua.edu.cn/apache/kylin/apache-kylin-3.1.2/apache-kylin-3.1.2-bin-hbase1x.tar.gz
```

4.制作hadoop-hbase-kylin镜像
<p>执行命令制作Docker镜像，并上传本地私服：

```bash
cd hbase
docker build -t hadoop-hbase-kylin .
docker tag hadoop-sqoop-spark repository:5000/hadoop-hbase-kylin
docker push repository:5000/hadoop-hbase-kylin
```
注意：将repository:5000改为你的本地私服地址:端口号
## Kubernetes安装部署
1.安装mysql

```bash
cd hive
kubectl apply -f mysql.yaml
```
2.安装hadoop

```bash
cd ../hbase/yaml
kubectl apply -f .
```
## 初始化hive数据库
### 第一次启动时，进入master节点：  
1.进入master节点的操作系统：

```bash
kubectl exec -it -n bigdata hadoop-master-0 -- bash
```

2.进入master节点后，执行以下命令初始化hive数据库：

```bash
schematool -dbType mysql -initSchema
```

### 执行以下命令初始化kylin:

```bash
cd $KYLIN_HOME/bin
bash kylin.sh start
```