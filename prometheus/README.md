# Kubernetes的系统监控Prometheus
这是Kubernetes的系统监控系统Prometheus的安装部署过程
## 在Kubernetes中埋点
执行脚本：

```bash
cd <安装目录>/prometheus
kubectl create -f ./yml/node-exporter.yaml
```
执行完以后进行检查：

```bash
$ kubectl get po -n kube-system |grep node-exporter
node-exporter-btclr                    1/1       Running   0          142d
node-exporter-rfxr9                    1/1       Running   0          142d
node-exporter-rw9qc                    1/1       Running   1          156d
```

## 安装部署Prometheus
建议将Prometheus部署在k8s之外，便于在k8s不正常时依然可以予以监控  
1.修改配置文件./server/prometheus.yml

```
global:
  scrape_interval:     15s
  evaluation_interval: 15s
rule_files:
  #加入告警的规则定义文件
  - "rules/*.yaml"
scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
      # 加入k8s上每个节点node-exporter的访问地址
      - targets: ['172.31.87.109:31100','172.31.87.110:31100','172.31.87.111:31100']
        labels: 
          group: 'client-node-exporter'
      - targets: ['172.31.87.111:9091']
        labels:
          group: 'pushgateway'
alerting:
  alertmanagers:
    - static_configs:
      - targets: ['172.31.87.111:9003']
```
2.部署Prometheus, pushgateway, alertmanager, grafana

```bash
docker run --name=prometheus -d -p 9090:9090 \
-v $PROMETHEUS_HOME/server/prometheus.yml:/etc/prometheus/prometheus.yml \
-v $PROMETHEUS_HOME/rules:/etc/prometheus/rules \
prom/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--web.enable-lifecycle

docker run -d -p 9091:9091 --name pushgateway prom/pushgateway
docker run -d -p 3000:3000 --name grafana grafana/grafana

docker run -d -p 9093:9093 --name alertmanager \
-v $PROMETHEUS_HOME/server/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
prom/alertmanager
```
3.最后，通过grafana访问系统监控：

```
http://localhost:3000/
```