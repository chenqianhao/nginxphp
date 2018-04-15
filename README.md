# nginxphp swoole1.9


NGING+PHP+REDIS Dockerfile
=================

基于最新版CentOS官方镜像

包含php，nginx，reids，oepnssh server，crond等服务。修改顶部的PHP_VER, NGINX_VER, REDIS_VER可构建任意版本的php，nginx，redis版本镜像。

1. 安装docker

```
wget -qO- https://get.docker.com/ | sh
```
2. 获取容器

```
sudo docker pull registry.cn-shenzhen.aliyuncs.com/chenqianhao/nginxphp:sd2
```
3. 获取配置文件

```
git clone git@github.com:chenqianhao/nginxphp.git

# 新建etc/nginx/sites.d文件夹，新增配置文件
```

4. 运行容器

- linux|mac
```
# 进入上面的配置文件夹 
sudo docker run -h nginxphp -p 80:80 -p 443:443 -p 8091:8091 -p 8081:8081 -p 8083:8083 -p 9999:9999 -p 6379:6379 --name nginxphp -itd -v $PWD/nginx/nginx.conf:/etc/nginx/nginx.conf -v $PWD/nginx/sites.d:/etc/nginx/sites.d  -v $PWD/nginx/rewrite:/etc/nginx/rewrite  -v $PWD/www:/www registry.cn-shenzhen.aliyuncs.com/chenqianhao/nginxphp:sd2

```
-  windows
```
mkdir  E:/docker/www  #新建网站目录
docker run -h nginxphp -p 80:80 -p 443:443 -p 8091:8091 -p 8081:8081 -p 8083:8083 -p 9999:9999 -p 6379:6379 --name nginxphp -itd -v E:/docker/nginxphp/sites.d:/etc/nginx/sites.d E:/docker/nginxphp/rewrite:/etc/nginx/rewrite -v E:/docker/www:/www registry.cn-shenzhen.aliyuncs.com/chenqianhao/nginxphp:sd2
```

