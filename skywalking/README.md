# 性能监控软件skywalking安装部署
性能监控软件skywalking在Kubernetes的分布式部署与应用
## 服务端的安装部署
从skywalking官网下载压缩包，并拷贝到server目录。
修改Dockerfile为刚才下载的压缩包名：
````
ADD apache-skywalking-apm-es7-8.6.0.tar.gz /
RUN mv /apache-skywalking-apm-bin-es7 /usr/local/skywalking
````
### 制作Docker镜像并上传私有仓库：
````bash
docker build -t <私有仓库>:5000/skywalking-oap-server .
docker push <私有仓库>:5000/skywalking-oap-server
````
### Kubernetes云部署
修改server/skywalking.yaml
````yaml
    spec:
      containers:
      - name: skywalking
        # 将镜像修改为<私有仓库>:5000/skywalking-oap-server
        image: repository:5000/skywalking-oap-server
        imagePullPolicy: Always
        command:
        - bash
        - "-c"
        - |
          bash startup.sh
          tail -f $SW_HOME/logs/skywalking-oap-server.log
        # 修改环境变量，这里用的是nacos作为注册中心及配置中心
        env:
          - name: SW_CLUSTER
            value: nacos
          - name: SW_SERVICE_NAME
            value: SkyWalking_OAP_Cluster
          - name: SW_CLUSTER_NACOS_HOST_PORT
            value: nacos-cluster:8848
          - name: SW_CLUSTER_NACOS_USERNAME
            value: nacos
          - name: SW_CLUSTER_NACOS_PASSWORD
            value: nacos
          - name: SW_CONFIGURATION
            value: nacos
          - name: SW_CONFIG_NACOS_SERVER_ADDR
            value: nacos-cluster
          - name: SW_CONFIG_NACOS_SERVER_PORT
            value: "8848"
          - name: SW_CONFIG_NACOS_SERVER_GROUP
            value: skywalking
          - name: SW_CONFIG_NACOS_USERNAME
            value: nacos
          - name: SW_CONFIG_NACOS_PASSWORD
            value: nacos
````
修改完成以后，还应当在nacos配置中心中配置数据库等信息，详见skywalking压缩包中config/application.yml。
最后执行脚本：
````
cd server
kubectl apply -f skywalking.yaml
````
## 制作java agent
Skywalking需要为每一个微服务所在的docker容器中安装agent，埋点采集数据。
将Skywalking压缩包中agent目录拷贝到本项目的agent目录中，制作agent镜像：
````
cd agent
docker build -t <私有镜像>:5000/skywalking-java-agent
docker push <私有镜像>:5000/skywalking-java-agent
````
有了该镜像以后，所有微服务在Kubernetes部署时，脚本应当这样编写：
````yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    app: edev-alibaba-trade-customer
  name: edev-alibaba-trade-customer
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: edev-alibaba-trade-customer
  template:
    metadata:
      name: edev-alibaba-trade-customer
      labels:
        app: edev-alibaba-trade-customer
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 50
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: "app"
                      operator: In
                      values:
                        - edev-alibaba-trade-customer
                topologyKey: "kubernetes.io/hostname"
      containers:
      - name: edev-alibaba-trade-customer
        image: repository:5000/edev-alibaba-trade-customer
        imagePullPolicy: Always
        command: ["java", "-Djava.security.egd=file:/dev/./urandom", "-javaagent:/var/lib/skywalking/agent/skywalking-agent.jar", "-jar", "/app.jar","--spring.profiles.active=docker"]
        env:
          - name: NACOS_ADDR
            value: "nacos-cluster:8848"
          - name: SW_AGENT_NAME
            value: "edev-alibaba-trade-customer"
          - name: SW_AGENT_COLLECTOR_BACKEND_SERVICES
            value: "skywalking:11800"
        volumeMounts:
        - name: skywalking
          mountPath: /var/lib/skywalking
      initContainers:
      - name: init
        image: repository:5000/skywalking-java-agent
        command: ['sh','-c','cp -r /agent /var/lib/skywalking']
        volumeMounts:
        - name: skywalking
          mountPath: /var/lib/skywalking
      volumes:
      - name: skywalking
        emptyDir: {}

---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: edev-alibaba-trade-customer
  name: edev-alibaba-trade-customer
  namespace: default
spec:
  ports:
  - port: 9002
    targetPort: 9002
  selector:
    app: edev-alibaba-trade-customer
````