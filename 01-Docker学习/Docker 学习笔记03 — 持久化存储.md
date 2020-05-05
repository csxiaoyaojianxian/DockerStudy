# Docker 学习笔记03

## 1. 持久化方案 

基于本地文件系统的 Volume

基于plugin的Volume

## 2. Data Volume / Bind Mouting

1. Data Volume 关联容器文件路径到主机，删除容器不会删除 Vloume，可以设置别名，如mysql-data

```
$ sudo docker run -d --name mysql -v mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=wordpress mysql
```

2. Bind Mouting 可以实现绑定本地文件夹，实现开发调试

```
$ sudo docker run -d -p 80:5000 -v $(pwd):/skeleton --name flask xxx/flask-skeleton
```





