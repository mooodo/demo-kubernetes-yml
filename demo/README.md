# 微服务Demo的Kubernetes部署
这是Demo-service-xxx系列的Kubernetes部署，部署时执行：

```bash
kubectl delete -f .
kubectl create -f .
```

该示例包含以下项目：

```bash
demo-parent             本示例所有项目的父项目，它集成了springboot, springcloud，并定义各项目如何maven打包
demo-service-eureka     微服务注册中心eureka的集群部署
demo-service-config     微服务配置中心config
demo-service-turbine    各微服务断路器运行状况监控turbine
demo-service-zuul       服务网关zuul
demo-service-parent     各业务微服务（无数据库访问）的父项目
demo-service-support    各业务微服务（无数据库访问）底层技术框架
demo-service-customer   用户管理微服务（无数据库访问）
demo-service-product    产品管理微服务（无数据库访问）
demo-service-supplier   供应商管理微服务（无数据库访问）
demo-service2-parent    各业务微服务（有数据库访问）的父项目
demo-service2-support   各业务微服务（有数据库访问）底层技术框架
demo-service2-customer  用户管理微服务（有数据库访问）
demo-service2-product   产品管理微服务（有数据库访问）
demo-service2-supplier  供应商管理微服务（有数据库访问）
demo-service2-order     订单管理微服务（有数据库访问）
```