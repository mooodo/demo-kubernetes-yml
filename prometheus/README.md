# Prometheus-Grafana
通过Prometheus实现对Kubernetes平台的系统监控，当出现问题时通过alertmanager进行告警，然后通过Grafana实现数据展示。

安装部署的要点：
## 1. 安装Kubernetes系统监控组件
分别进入目录kube-state-metrics与metric-server执行脚本安装部署监控组件：
```shell
kubectl apply -f .
```
## 2. 对Kubernetes平台埋点
通过部署node-exporter.yaml，实现对Kubernetes平台的埋点：
```shell
kubectl apply -f node-exporter.yaml
```
## 3. 安装Prometheus
通过部署prometheus.yaml，部署Prometheus：
### 数据与配置如何存储
现在默认存储是本地存储，如果要改为网络，修改配置并执行prometheus-pv.yaml，然后将本脚本改为网络存储
### 对外访问端口号
现在默认是30090，按需自行修改

执行脚本：
```shell
kubectl apply -f prometheus.yaml
```
## 4. 安装Grafana
Prometheus收集的数据是通过Grafana来进行展现：
### 数据与配置如何存储
现在默认存储是本地存储，如果要改为网络，修改配置并执行grafana-pv.yaml，然后将本脚本改为网络存储
### 对外访问端口号
现在默认是30300，按需自行修改

执行脚本：
```shell
kubectl apply -f grafana.yaml
```
## 5. 安装alertmanager
进入脚本alertmanager.yaml，修改告警的相关配置alertmanager.yml，执行脚本：
```shell
kubectl apply -f alertmanager.yaml
```
## 6. 安装钉钉告警
如果需要通过钉钉进行告警，先在钉钉的群组中创建机器人，然后安装dingtalk.yaml