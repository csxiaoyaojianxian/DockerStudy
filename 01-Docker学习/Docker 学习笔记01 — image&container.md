# Docker 学习笔记01

## 1. 环境安装

1. vagrant + VirtualBox
2. docker-machine + VirtualBox
3. docker playground

安装 vagrant + VirtualBox 快速搭建 Docker host，不推荐直接使用 Docker for Mac

```
# 初始化 Vagrantfile 文件
$ vagrant init centos/7
# 安装 centos7 虚拟机
$ vagrant up
# ssh进入虚拟机
$ vagrant ssh

> sudo yum update
# 退出
> exit
```

vagrant 虚拟机镜像管理

```
$ vagrant status
# 停止
$ vagrant halt
# 删除
$ vagrant destroy
```

**虚拟机中 docker 安装方式1**

按照官方教程安装 docker <https://docs.docker.com/engine/install/centos/> 并验证

```
$ sudo docker version
$ sudo systemctl start docker
$ sudo docker run hello-world
```

**虚拟机中 docker 安装方式2**

还可以直接通过配置 Vagrantfile 文件

```Shell
config.vm.provision "shell", inline: <<-SHELL
    sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
SHELL
```

然后启动
```
$ vagrant up
```

**docker-machine工具**

可以不通过 vagrant 创建虚拟机，但是同样依赖 virtualbox

```
# 创建 docker - demo
$ docker-machine create demo
$ docker-machine ls
$ docker-machine ssh demo
$ exit
$ docker-machine stop demo
$ docker-machine env demo
```

## 2. Docker image & container

image 的获取途径

1. Dockerfile 构建

2. pull from registry —— dockerhub

```
$ sudo docker image ls
```

container

```
$ sudo docker container ls -a
# 交互式运行，创建container
$ sudo docker run -it centos
$ sudo docker container rm xxx
```

两种镜像创建方式：docker commit / docker build
```
# 在一个 container 基础上创建新 image
$ sudo docker container commit
# 等同于
$ sudo docker commit
$ sudo docker login
$ sudo docker push xxx/xxx:latest
$ sudo docker pull xxx/xxx

# 基于 Dockerfile 创建 image，推荐
$ sudo docker image build
# 等同于
$ sudo docker build
```

例如：创建包含 vim 的 image

Dockerfile

```
FROM centos
RUN yum install -y vim
```

```
$ sudo docker build -t csxiaoyao/centos-vim .
```

## 3. Dockerfile 语法

两种写法：shell (完整的一行)、exec (参数数组的形式)

**FROM**，尽量使用官方 image 作为 base image

```
FROM scratch  # 制作 base image
FROM centos  # 制作 base image
FROM ubuntu:14.04
```

**LABEL**，定义 image 的 Metadata，类似注释，不可少

```
LABEL version="1.0"
LABEL description="test"
```

**RUN**，执行命令并创建新的 Image Layer，尽量合并一行，避免无用分层，为了美观，复杂的 RUN 可使用反斜线换行

```
RUN yum update && yum install -y vim \
    python-dev
```

**WORKDIR**，不要用 RUN cd，尽量用绝对路径

```
WORKDIR /test
WORKDIR demo
RUN pwd      # 输出 /test/demos
```

**ADD / COPY**，把本地文件添加到指定位置，ADD 相比 COPY 还可以自动解压缩，添加远程文件/目录使用 curl / wget

```
ADD test.tar.gz /  # 添加到根目录并解压
WORKDIR /root
ADD hello test/    # /root/test/hellos
```

**ENV**，常量，增强可维护性

```
ENV MYSQL_VERSION 5.6  # 设置常量
RUN apt-get install -y mysql-server="${MYSQL_VERSION}" \
    && rm -rf /var/lib/apt/lists/*
```

**VOLUME / EXPOST**

存储和网络

**CMD**，设置容器启动后默认执行的命令和参数，若 docker run 指定了其他命令，CMD 会被忽略，若定义了多个 CMD，只有最后一个会执行

**ENTRYPOINT**，设置容器启动时运行的命令，让容器以应用程序或服务的形式运行，不会被忽略，推荐写一个 shell 脚本作为 entrypoint

```
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSR 27017
CMD ["mongod"]
```

## 4. Dockerfile 实战

### 4.1 运行后台 web application 服务

Dockerfile主要包含三块：环境、代码、运行，参考 `05-flask-hello-world` 的 Dockerfile，build并运行

```
$ docker build -t xxx/flask-hello-world .
```

调试，build 时候每层会创建临时的 container，进入 container id 调试

```
$ docker run -it 4320f8b52 /bin/bash
```

后台运行

```
$ docker run -d xxx/flask-hello-world
```

### 4.2 运行一个非常驻工具 

参考 `06-ubuntu-stress` 的 Dockerfile，关注 ENTRYPOINT 和 CMD 的方式命令行传参，运行 stress 程序

```
# --vm 1 --verbose 都作为参数传入 CMD
$ docker run -it xxx/ubuntu-stress --vm 1 --verbose
```

### 4.3 容器资源限制

`--memory` 、`--cpu-shares` 设置内存和权重

```
$ docker run --cpu-shares=10 --memory=200M xxx/ubuntu-stress --vm 1 --verbose
```

### 4.4 container 操作

exec 用于对容器执行命令

```
$ docker exec -it 11a767 /bin/bash # 进入shell
$ docker exec -it 11a767 python
$ docker exec -it 11a767 ip a   # 打印容器ip
```

docker操作

```
$ docker ps
$ docker stop 11a767
$ docker ps -a
$ docker rm $(docker ps -aq)   # 清除所有退出的容器
```

其他

```
$ docker inspect 11a767  # 查看详情
$ docker log 11a767
```

