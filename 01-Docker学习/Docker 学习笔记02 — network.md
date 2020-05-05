# Docker 学习笔记02

## 1. 环境搭建 

创建两个虚拟机，参考 Vagrantfile 配置文件，启动

```
$ vagrant up
$ vagrant status
$ vagrant ssh docker-node1
```

ping 验证IP可达性，telnet 验证服务可用性(端口)

```
$ ping 192.168.205.10
$ telnet 192.168.205.10 80
```

## 2. network 

```
$ sudo docker network ls
$ sudo docker network inspect bridge
```

端口映射，容器中的80端口映射到本地的80端口

```
$ sudo docker run --name web -d -p 80:80 nginx
```

## 3. demo

Py-flask web application 需要访问 redis，参考源码 `flask-redis`

创建 redis 容器仅供 flask app 访问（未做端口6379的映射 -p 6379:6379）

```
$ sudo docker run -d --name redis redis
$ sudo docker ps
```

为 flask-redis 的 web app 创建 link 到 redis 容器上，并设置环境变量 REDIS_HOST=redis，同时映射本地端口 5000 到 flask-redis 的 5000 端口

```
$ sudo docker run -d -p 5000:5000 --link redis --name flask-redis -e REDIS_HOST=redis xxx/flask-redis
```

## 4. 多机器通信

通过 oerlay 网络实现通信，通过 etcd 工具实现分布式不重复IP分配







