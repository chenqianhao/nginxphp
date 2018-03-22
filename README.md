# nginxphp


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
sudo docker pull registry.cn-hangzhou.aliyuncs.com/cqh/nginxphp:1.0.0
```
3. 获取配置文件

```
git clone git@github.com:chenqianhao/nginxphp.git

# 新建etc/nginx/sites.d文件夹，新增配置文件
```

4. 运行容器

- linux
```
# 进入上面的配置文件夹 -v $PWD/cron.d:/etc/cron.d -v $PWD/data/log:/var/log
sudo docker run -h nginxphp -p 80:80 -p 443:443 -p 1314:22 -p 11211:11211 -p 6379:6379 --name nginxphp -itd -v $PWD/nginx/nginx.conf:/etc/nginx/nginx.conf -v $PWD/nginx/sites.d:/etc/nginx/sites.d  -v $PWD/nginx/rewrite:/etc/nginx/rewrite  -v $PWD/www:/www  registry.cn-hangzhou.aliyuncs.com/cqh/nginxphp:1.0.0

```
-  windows  -v E:/docker/lnmp/data/log:/var/log
```
mkdir  E:/docker/www  #新建网站目录
docker run -h cqhlnmp -p 80:80 -p 1314:22 -p 11211:11211 -p 6379:6379 --name nginxphp -itd -v E:/docker/lnmp/vhosts:/etc/nginx/sites.d -v E:/docker/www:/www registry.cn-hangzhou.aliyuncs.com/cqh/nginxphp:1.0.0
```

5.xhprof使用方法
```
    xhprof_enable();

    //你需要分析的代码

    $xhprof_data = xhprof_disable();
    include_once 'xhprof_lib/utils/xhprof_lib.php';//注xhprof_lib已经在/usr/local/php/lib/php中了
    include_once 'xhprof_lib/utils/xhprof_runs.php';

    $xhprof_runs = new XHProfRuns_Default();
    $run_id = $xhprof_runs->save_run($xhprof_data, "xhprof_test");
    //将run_id保存起来或者随代码一起输出

```
＊ 然后访问:http://nginx默认站点或域名/xhpfrof_html/index.php?run=run_id&source=xhprof_test查看结果。
