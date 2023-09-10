# ElasticSearch-Fluentd-Kibana
EFK是Kubernetes平台的日志采集与分析方案，Fluentd通过埋点采集那些部署在Kubernetes平台各应用的日志，将其存储在ElasticSearch中，最后通过Kibana进行日志的查找、展现与分析。

安装部署过程注意以下要点：
- 默认安装不需要进行任何修改，直接执行以下脚本：
```shell
kubectl apply -f .
```
- 默认安装的是单节点的ElasticSearch，可以通过修改es-statefulset.yaml调整其部署

- 如果采用其它的ElasticSearch，需要修改以下脚本：
  + 修改fluentd-es-configmap.yaml最后几行，output.conf中关于ElasticSearch的配置
  + 修改kibana-deployment.yaml中关于ElasticSearch的环境变量ELASTICSEARCH_HOSTS