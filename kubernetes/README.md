# Kubernetes的安装部署
这是一个Kubernetes的安装部署过程，版本是1.11.0

## 准备工作
写入hosts

```bash
echo "10.211.55.18    k8s-master-1
10.211.55.19    k8s-node-1
10.211.55.20    k8s-node-2" >> /etc/hosts
```
关闭防火墙

```bash
systemctl stop firewalld
systemctl disable firewalld
```
禁用SELINUX

```bash
setenforce 0
vi /etc/selinux/config 
#SELINUX=disabled
```
开启ipvs，kube-proxy开启ipvs的前置条件需要加入以下内核模块：

```bash
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```

关闭swap

```bash
swapoff –a
```
修改 /etc/fstab 文件，注释掉 SWAP 的自动挂载，使用free -m确认swap已经关闭。 swappiness参数调整，修改/etc/sysctl.d/k8s.conf添加下面一行：
vm.swappiness=0
执行生效：

```bash
sysctl -p /etc/sysctl.d/k8s.conf
```

## 安装Docker (所有节点都要执行)
1.检查linux内核版本

```bash
uname -r
```
2.使用 root 权限登录 Centos，确保 yum 包更新到最新，但可能会报错说没有定义yum仓库

```bash
yum update
```
3.安装需要的软件包，其中yum-util提供yum-config-manager功能

```bash
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```
4.设置docker的yum源

```bash
$ yum-config-manager \
--add-repo https://download.docker.com/linux/centos/docker-ce.repo
```
5.查看各docker版本

```bash
$ yum list docker-ce --showduplicates | sort -r
```
6.安装docker

```bash
$ yum install docker-ce-17.12.0.ce
```

## 使用kubeadm部署Kubernetes
### 1.添加阿里的源(所有节点都执行)
官网是：

```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```
现改为阿里的源：

```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```
安装必要组件：

```bash
yum -y install epel-release
yum clean all
yum makecache fast
yum -y install kubelet-1.11.7-0.x86_64 kubeadm-1.11.7-0.x86_64 kubectl-1.11.7-0.x86_64 kubernetes-cni
systemctl enable kubelet && systemctl start kubelet
```
下载启动k8s所需的所有容器：  
注意：安装k8s最大的难题是不能直接从google网站下载，因此采用这种方式

```bash
cd <安装目录>/kubernetes
chmod -R 777 ./xxx.sh
./xxx.sh
```

### 2.使用kubeadm init初始化集群（仅master上执行）
启动k8s主节点

```bash
kubeadm init --kubernetes-version=v1.11.0 --pod-network-cidr=10.244.0.0/16
```

记住控制台输出的最后一句话，类似：

```bash
kubeadm join 172.19.1.109:6443 --token 8b1jm7.6951eviubal4x39q --discovery-token-ca-cert-hash sha256:6412
50cfbffae1e857a26d83c1e79f3d4c7d2759359e868406375784be1c1626
```
每次执行init的token都不一样，这是其它节点加入主节点的命令  

如果要停机k8s集群在每个节点执行：

```bash
kubeadm reset
```

初次启动以后执行一下命令：

```bash
mkdir -p ~/.kube
cp -i /etc/kubernetes/admin.conf ~/.kube/config
chown $(id -u):$(id -g) ~/.kube/config
```

配置 kubectl 认证信息

```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
```
### 3.安装 Flannel 网络（仅master上执行）

```bash
mkdir -p /etc/cni/net.d/

cat <<EOF> /etc/cni/net.d/10-flannel.conf
{
“name”: “cbr0”,
“type”: “flannel”,
“delegate”: {
“isDefaultGateway”: true
}
}
EOF

mkdir /usr/share/oci-umount/oci-umount.d -p

mkdir /run/flannel/

cat <<EOF> /run/flannel/subnet.env
FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.1.0/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF
```
执行脚本：

```bash
kubectl create -f ./flannel.yml
```
检查运行状态，执行：

```bash
kubectl -n kube-system get pods
```
得到结果：

```
NAME                                   READY     STATUS    RESTARTS   AGE
coredns-78fcdf6894-ddb54               1/1       Running   0          1h
coredns-78fcdf6894-qqqxf               1/1       Running   0          1h
etcd-172-19-1-109                      1/1       Running   0          1h
kube-apiserver-172-19-1-109            1/1       Running   0          1h
kube-controller-manager-172-19-1-109   1/1       Running   0          1h
kube-flannel-ds-zq9ns                  1/1       Running   0          50m
kube-proxy-hs89s                       1/1       Running   0          1h
kube-scheduler-172-19-1-109            1/1       Running   0          1h
```
如果所有节点都处于Running状态，主节点安装成功

## 加入worker节点(所有从节点执行)
依次在每个从节点上执行join操作：

```bash
kubeadm join 172.19.1.109:6443 --token 8b1jm7.6951eviubal4x39q --discovery-token-ca-cert-hash sha256:641250cfbffae1e857a26d83c1e79f3d4c7d2759359e868406375784be1c1626
```

注意：每次主节点reset以后，会生成一个新的token，因此每个从节点需要先执行kubeadm reset，然后再执行join操作。  

回到master节点执行：

```bash
kubectl get nodes
```
得到结果：

```
NAME        STATUS   ROLES    AGE   VERSION
k8s-master-1   Ready    master   10d   v1.11.7
k8s-node-1    Ready    <none>   10d   v1.11.7
k8s-node-2    Ready    <none>   10d   v1.11.7
```
如果都是Ready状态，表明k8s集群安装成功！如果有NotReady状态，检查集群安装过程，最大可能是Flannel虚拟网络未正确安装。

## 安装Dashboard
执行命令：

```bash
cd dashboard
kubectl  -n kube-system create -f .
```
