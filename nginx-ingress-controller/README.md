# nginx-ingress-controller
nginx-ingress-controller是kubernetes平台的入口流量技术方案，要部署该方案应注意以下要点：

### 部署负载均衡
首先应在kubernetes平台之外，为nginx-ingress-controller部署一个负载均衡（如LVS, HAProxy等），接收所有用户入口流量，然后再负载均衡到nginx-ingress-controller的多个节点中。
### 多节点部署nginx-ingress-controller
mandatory.yaml是官方脚本，nginx-ingress-controller.yaml是改进版本，它首先将nginx-ingress-controller.yaml改为DaemonSet部署，部署前需要在Kubernetes平台各Node节点上打标签：
```shell
kubectl label nodes node1 ingress=
```
通过该标签控制nginx-ingress-controller的部署，有多少个Node节点打了这个标签，就会部署多少个节点。
### 配置负载均衡
将部署了nginx-ingress-controller的Node节点，其物理IP地址配置到负载均衡中，实现入口流量的负载均衡