# 在Kubernetes中安装部署MySQL
这是一个演示在Kubernetes中安装部署MySQL
## 本地磁盘部署
在Kubernetes中多节点部署MySQL，每个节点的数据存储在本地磁盘中，执行脚本：

```bash
kubectl apply -f mysql.yaml
```
部署成功后，每个节点的MySQL通过hostPath将数据文件存储在本地磁盘挂载中。
### 数据库访问
这里采用了无头的Service：
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  ports:
  - port: 3306
  selector:
    app: mysql
  clusterIP: None
```
可以通过`mysql-0.mysql、mysql-1.mysql、mysql-2.mysql`访问每个节点，例如：
```
jdbc:mysql://mysql-0.mysql:3306/demo?useUnicode=true&characterEncoding=UTF-8&serverTimezone=GMT%2B8
```
如果需要在Kubernetes集群之外访问MySQL，使用普通的Service，端口号是32306。
````yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-svc
spec:
  type: NodePort
  ports:
  - name: http
    port: 3306
    targetPort: 3306
    nodePort: 32306
  selector:
    app: mysql
````
### 集群管理
由于采用了本地磁盘挂载，集群管理上必须采用硬亲和性，即每个物理节点只能部署一个MySQL的方式。
```yaml
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: "app"
                    operator: In
                    values:
                      - mysql
              topologyKey: "kubernetes.io/hostname"
```
### 高可用
本方案还不能保证高可用。如果要做高可用，可以在此基础上为每个MySQL节点建立主从同步。

## 网络磁盘部署
要在Kubernetes中进行高可用的部署，可以通过云端平台的网络存储设备存储数据，执行脚本：
````bash
kubectl apply -f mysql-pv.yaml
````
部署成功后，首先为网络存储设备nfs建立了一个持久化存储卷：
````yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: mysql-pv-volume
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: nfs
  nfs:
    path: /data/nfs/mysql
    server: 172.31.87.111
````
接着，MySQL在部署时，通过pvc将数据存储在网络磁盘挂载中。
这样，MySQL在本地不再存储数据，因此不必采用StatefulSet进行部署，而是采用Deployment进行无状态部署。
通过这种部署方式，就可以利用Kubernetes的高可用，即使MySQL出现宕机，也可以立即在另一个节点再启动一个，保证高可用。
但该方式部署的MySQL只能是一个节点。
