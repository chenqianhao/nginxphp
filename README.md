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

3. 运行容器

- linux|mac
```
# 进入上面的配置文件夹 
sudo docker run -h sd2 -p 8091:8091 -p 8081:8081 -p 8083:8083 -p 9999:9999 -p 6379:6379 --name sd2 -itd -v $PWD/www:/www registry.cn-shenzhen.aliyuncs.com/chenqianhao/nginxphp:sd2

```
-  windows
```
mkdir  E:/docker/www  #新建网站目录
docker run -h sd2 -p 8091:8091 -p 8081:8081 -p 8083:8083 -p 9999:9999 -p 6379:6379 --name sd2 -itd  -v E:/docker/www:/www registry.cn-shenzhen.aliyuncs.com/chenqianhao/nginxphp:sd2
```
4. 安装sd框架（参考官方composer安装方法）
* 进入容器
```
sudo docker exec -it sd2 /bin/bash
mkdir -p /www/sd && cd /www/sd
```
```
vim composer.json
{
  "require": {
    "tmtbe/swooledistributed":"2.*"
  },
 "autoload": {
    "psr-4": {
      "app\\": "src/app",
      "test\\": "src/test"
    }
  }
}

```
```
composer install
php vendor/tmtbe/swooledistributed/src/Install.php
```
* 启动sd框架
```
cd /www/sd/bin && php start_swoole_server.php start
```
* 错误处理
![image](http://oxnd75eqj.bkt.clouddn.com/UC20180402_145545.png)
> 默认配置中有写redis默认密码，此处为：CQH123456789，如有修改请按照真实情况填写
![image](http://oxnd75eqj.bkt.clouddn.com/UC20180402_150131.png)

* 正常启动sd框架
![image](http://oxnd75eqj.bkt.clouddn.com/UC20180402_150231.png)
