# nginxphp


NGING+PHP+REDIS Dockerfile
=================

基于最新版CentOS官方镜像

包含php，nginx，reids，oepnssh server，crond等服务。修改顶部的PHP_VER, NGINX_VER, REDIS_VER可构建任意版本的php，nginx，redis版本镜像。

1. 安装docker(加速器自行配置)

```
wget -qO- https://get.docker.com/ | sh
```
2. 获取容器

```
sudo docker pull registry.cn-shenzhen.aliyuncs.com/chenqianhao/nginxphp
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
sudo docker run -h nginxphp -p 80:80 -p 443:443 -p 8091:8091 -p 8081:8081 -p 8083:8083 -p 9999:9999 -p 6379:6379 --name nginxphp -itd --restart=always -v $PWD/nginx/nginx.conf:/etc/nginx/nginx.conf -v $PWD/nginx/sites.d:/etc/nginx/sites.d  -v $PWD/nginx/rewrite:/etc/nginx/rewrite  -v $PWD/www:/www registry.cn-shenzhen.aliyuncs.com/chenqianhao/nginxphp

```
-  windows  
```
#mkdir  E:/docker/www  #新建网站目录
docker run -h nginxphp -p 80:80 -p 443:443 -p 8091:8091 -p 8081:8081 -p 8083:8083 -p 9999:9999 -p 6379:6379 --name nginxphp -itd -v E:/docker/nginxphp/sites.d:/etc/nginx/sites.d E:/docker/nginxphp/rewrite:/etc/nginx/rewrite -v E:/docker/www:/www registry.cn-shenzhen.aliyuncs.com/chenqianhao/nginxphp
```
> 新增网站都放入nginx/sites.d文件下，以.conf文件结尾，rewrite文件放入nginx/rewrite目录下

5. 进入容器安装SwooleDistributed矿建
* 进入容器
```
sudo docker exec -it nginxphp /bin/bash
mkdir -p /www/sd && cd /www/sd
```
* 安装最新的sd框架
```
vim composer.json
{
  "require": {
    "tmtbe/swooledistributed":">2.0.0"
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
