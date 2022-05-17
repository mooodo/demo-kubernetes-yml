# Kubernetes的系统监控Prometheus
这是Kubernetes的系统监控系统Prometheus的安装部署过程
## 制作prometheus-rules
制作一个prometheus-rules的docker镜像，将所有prometheus的rule都放到该镜像中

```bash
cd rules
docker build -t <私有镜像IP>:5000/prometheus-rules .
docker push <私有镜像IP>:5000/prometheus-rules
```
## 安装部署Prometheus
修改prometheus.yaml中initContainer为刚才制作的镜像：
````yaml
      initContainers:
        - name: init
          # 修改为<私有镜像IP>:5000/prometheus-rules
          image: repository:5000/prometheus-rules
          command: ['sh','-c','cp -r /rules /etc/prometheus']
          volumeMounts:
            - name: rules
              mountPath: /etc/prometheus/rules
````
执行安装目录下的安装脚本：
````bash
cd <安装目录>
kubectl apply -f .
````
## 通过grafana访问系统监控：
```
http://localhost:3000/
```
默认用户/密码：grafana/grafana
## 安装kube-stats-metric
为了更好地监控Kubernetes，可以安装Kubernetes的监控组件：
````bash
cd kube-stats-metric
kubectl apply -f .
````