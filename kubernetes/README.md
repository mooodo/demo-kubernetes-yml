# 安装Kubernetes 1.20
## 准备工作
### 1. 设置hosts
```shell
cat <<EOF > /etc/hosts
192.168.211.10 master
192.168.211.11 node1
192.168.211.12 node2
192.168.211.13 node3
EOF
```
### 2. 进行linux相关配置
```shell
setenforce  0
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config

systemctl stop firewalld
systemctl disable firewalld

swapoff -a
sed -i 's/.*swap.*/#&/' /etc/fstab

cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p /etc/sysctl.d/k8s.conf
echo "* soft nofile 655360" >> /etc/security/limits.conf
echo "* hard nofile 655360" >> /etc/security/limits.conf
echo "* soft nproc 655360"  >> /etc/security/limits.conf
echo "* hard nproc 655360"  >> /etc/security/limits.conf
echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
echo "* hard memlock  unlimited"  >> /etc/security/limits.conf
echo "DefaultLimitNOFILE=1024000"  >> /etc/systemd/system.conf
echo "DefaultLimitNPROC=1024000"  >> /etc/systemd/system.conf
ulimit -Hn
```
## 安装Docker（所有节点）
### 1. 检查linux内核版本
``uname -r``
### 2. 使用 root 权限登录 Centos，确保 yum 包更新到最新
```yum update```
### 3. 安装需要的软件包，其中yum-util提供yum-config-manager功能
```sudo yum install -y yum-utils device-mapper-persistent-data lvm2```
### 4. 设置docker的yum源
```shell
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```
### 5. 安装docker
``yum install docker-ce -y``
### 6. 配置容器加速器（阿里云）
```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
      "registry-mirrors": ["https://rpbig1xh.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```
## 安装Kubernetes（所有节点）
### 1. 使用yum进行安装
```shell
rm -rf  /etc/yum.repos.d/*
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.cloud.tencent.com/repo/epel-7.repo
```
```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg  
EOF
yum clean all && yum makecache

yum install  -y conntrack ipvsadm ipset jq sysstat curl iptables libseccomp bash-completion yum-utils device-mapper-persistent-data lvm2 net-tools conntrack-tools vim libtool-ltdl

yum -y install chrony
systemctl enable chronyd.service && systemctl start chronyd.service && systemctl status chronyd.service
chronyc sources

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet && systemctl start kubelet
```
### 2. 下载相关Docker镜像
```shell
cat <<EOF > pull-k8s-images.sh
#!/bin/bash
images=(
kube-apiserver:v1.20.4
kube-controller-manager:v1.20.4
kube-scheduler:v1.20.4
kube-proxy:v1.20.4
pause:3.2
etcd:3.4.13-0
coredns:1.7.0
)
for imageName in ${images[@]} ; do
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done
EOF

chmod 777 pull-k8s-images.sh
./pull-k8s-images.sh
```
## 启动Kubernetes
### 1. 启动Kubernetes主节点
```shell
kubeadm init --kubernetes-version=v1.20.4 --pod-network-cidr=10.244.0.0/16
```
**注意：**
+ 启动过程中记录下类似以下内容：
```shell
kubeadm join 172.31.87.109:6443 --token n8tu9g.w7tqh4mqn6895z2l \
--discovery-token-ca-cert-hash sha256:47b9dc4c420ce8491e05948e5115774a481fc90f5ca3113cc97dd77a30d98399
```
+ 如果没有记录以上内容，或者日后有节点需要加入，可以执行以下命令重新创建：
```shell
kubeadm token create --print-join-command
```
1) 执行以下命令：
```shell
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```
2) 启动flannel虚拟网络：
```shell
curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml -O
kubectl apply -f kube-flannel.yml
```
3) 检查Kubernetes是否正常启动：
```shell
kubectl get nodes
```
## 启动Kubernetes从节点
+ 执行加入命令：
```shell
kubeadm join 172.31.87.109:6443 --token n8tu9g.w7tqh4mqn6895z2l \
--discovery-token-ca-cert-hash sha256:47b9dc4c420ce8491e05948e5115774a481fc90f5ca3113cc97dd77a30d98399
```
+ 日后执行加入命令先执行以下命令获得token：
```shell
kubeadm token create --print-join-command
```
+ 检查Kubernetes是否正常启动：
```shell
kubectl get nodes
kubectl get po -n kube-system
```
## 安装控制台Dashboard
```shell
curl https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml -O
```
### 修改该文件以下内容：
```yaml
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  type: NodePort # 修改为外部可访问
  ports:
  - port: 443
    targetPort: 8443
    nodePort: 30443 # 设置外部网络端口
  selector:
    k8s-app: kubernetes-dashboard
```
### 执行命令
```shell
kubectl apply -f recommended.yaml
```
### 查看token：
```shell
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep dashboard-admin | awk '{print $1}')
```
访问：https://<k8s任意节点>:30443，选择Token登录，粘贴刚才生成的token
## 安装kube-state-metrics
```shell
cd kube-state-metrics
kubectl apply -f .
```
## 安装metric-server
### 下载yaml文件
```shell
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
### 下载Docker镜像
```shell
docker pull bitnami/metrics-server:0.4.2
docker tag bitnami/metrics-server:0.4.2 k8s.gcr.io/metrics-server/metrics-server:v0.4.2
```
### 修改yaml文件以下内容：
```yaml
    spec:
      containers:
        - args:
            - --cert-dir=/tmp
            - --secure-port=4443
            - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
            - --kubelet-use-node-status-port
            - --kubelet-insecure-tls
```
### 执行命令
```shell
$ kubectl apply -f components.yaml
$ kubectl -n kube-system get deploy metrics-server
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           3d
```
### 查看node资源
```shell
$ kubectl top nodes
NAME         CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s-master   258m         12%    880Mi           23%       
k8s-node1    96m          4%     562Mi           14%       
k8s-node2    139m         6%     601Mi           15%
```
### 查看pod资源
```shell
$ kubectl -n kube-system top pods
NAME                                 CPU(cores)   MEMORY(bytes)   
coredns-bccdc95cf-5wqq6              4m           12Mi            
coredns-bccdc95cf-p8xzq              3m           11Mi            
etcd-k8s-master                      21m          52Mi            
kube-apiserver-k8s-master            32m          268Mi           
kube-controller-manager-k8s-master   15m          42Mi            
kube-flannel-ds-amd64-pgwgb          3m           14Mi            
kube-flannel-ds-amd64-v5j5q          3m           13Mi            
kube-flannel-ds-amd64-zjpq8          2m           11Mi            
kube-proxy-nf688                     1m           15Mi            
kube-proxy-tfb6q                     1m           15Mi            
kube-proxy-wsx7d                     4m           15Mi            
kube-scheduler-k8s-master            2m           12Mi            
metrics-server-7ccb6455b9-nzhck      1m           12Mi
```
