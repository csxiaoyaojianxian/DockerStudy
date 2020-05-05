# Docker 学习笔记04

## 1. 已学知识安装wordpress 

创建mysql容器，参考 [](https://hub.docker.com/_/mysql)，内网访问不用设置 -p，设置volume别名 mysql-data

```
$ sudo docker run -d --name mysql -v mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=wordpress mysql
```

创建wordpress容器，参考 [](https://hub.docker.com/_/wordpress)，--link，允许wordpress直接访问mysql

```
$ sudo docker run -d -e WORDPRESS_DB_HOST=mysql:3306 --link mysql -p 8080:80 wordpress
```

本地浏览器访问 127.0.0.1:8080 进行安装，提示数据库连接失败，查看日志

```
$ docker logs mysql
```

提示认证方法错误，因为mysql8.0以后默认的认证方式改变

```
$ docker exec -it mysql /bin/bash
$ mysql -u root -p
> use mysql;
#开启root远程访问权限
> grant all on *.* to 'root'@'%';
#修改加密规则
> alter user 'root'@'localhost' identified by 'root' password expire never;
#更新密码
> alter user 'root'@'%' identified with mysql_native_password by 'root';
#刷新权限
> flush privileges;
```

## 2. docker compose

通过 docker-compose.yml 管理 docker 组，但是 **只适用于单机**

services 代表一个 container，启动 service 类似 docker run

语法参考 `04/01-wordpress/docker-compose.yml`

dockerfile相关语法参考 `04/02-flask-redis/docker-compose.yml`

Linux 需要独立安装，参考 [](https://docs.docker.com/compose/install/)

```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose --version
```

运行

```
$ docker-compose up
$ docker-compose up -d

$ docker-compose ps
$ docker-compose stop
$ docker-compose start
# stop 并删除资源
$ docker-compose down

$ docker-compose exec wordpress bash
$ docker-compose exec mysql bash
```

## 3. 水平扩展和负载均衡 

--scale，参考 `04/03-lb-scale/docker-compose.yml` 中的 lb service 使用了 image: dockercloud/haproxy

```
$ docker-compose up --scale web=3 -d
```

## 4. 复杂投票应用的配置

参考 `04/04-example-voting-app/docker-compose.yml`，投票打开 `127.0.0.1:5000`，查看结果打开 `127.0.0.1:5001`

