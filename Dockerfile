FROM centos:latest
MAINTAINER chenqianhao 68527761@qq.com

#root用户密码
#ENV ROOT_PASSWORD=123456789
#php版本,因为php版本间配置文件模板不相同，此处的版本号只能为大于7.0以上版本
ENV PHP_VER=7.1.13
#nginx版本
ENV NGINX_VER=1.13.8
#redis版本
ENV REDIS_VER=3.2.11
#redis密码
ENV REDIS_PASS=CQH123456789
#memcached版本
ENV MEMCACHED_VER=1.5.3
#node版本
ENV NODE_VER=v9.0.0
#时区
ENV TZ=Asia/Shanghai
#运行用户
ENV USER=www
ENV GROUP=www

#修改dns地址
RUN echo nameserver 223.5.5.5 > /etc/resolv.conf

#更换yum源
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo


#安装基础工具
RUN yum install vim wget git net-tools ansible zip unzip libmemcached sudo -y

#时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && yum install ntp -y && ntpdate pool.ntp.org

#安装中文支持
RUN yum -y install kde-l10n-Chinese && yum -y reinstall glibc-common
#配置显示中文
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
#设置环境变量
ENV LC_ALL zh_CN.utf8

#安装supervisor
RUN  yum install python-setuptools -y && easy_install supervisor

#安装openssh server
RUN yum install openssh-server -y
RUN echo PermitRootLogin  yes >> /etc/ssh/sshd_config\
    && echo PasswordAuthentication yes >> /etc/ssh/sshd_config\
    && echo RSAAuthentication yes >> etc/ssh/sshd_config\
    && sed -i "s/UseDNS yes/UseDNS no/" /etc/ssh/sshd_config\
    && echo "root:$ROOT_PASSWORD" | chpasswd\
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_rsa_key\
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_ecdsa_key\
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_ed25519_key

#安装php
RUN yum install epel-release -y && yum update -y \
    && yum -y install cronie pcre pcre-devel zlib zlib-devel openssl openssl-devel libxml2 libxml2-devel libjpeg libjpeg-devel libpng libpng-devel curl curl-devel libicu libicu-devel libmcrypt  libmcrypt-devel freetype freetype-devel libmcrypt libmcrypt-devel autoconf gcc-c++
WORKDIR /usr/src
RUN wget -O php.tar.gz "http://php.net/get/php-${PHP_VER}.tar.gz/from/this/mirror" && mkdir php && tar -xzvf php.tar.gz -C ./php --strip-components 1
WORKDIR php
RUN ./configure --prefix=/usr/local/php --with-config-file-path=/etc/php --with-fpm-user=$USER --with-fpm-group=$GROUP --enable-soap --enable-mbstring=all --enable-sockets --enable-fpm --with-gd --with-freetype-dir=/usr/include/freetype2/freetype --with-jpeg-dir=/usr/lib64 --with-zlib --with-iconv --enable-libxml --enable-xml  --enable-intl --enable-zip --enable-pcntl --enable-bcmath --enable-maintainer-zts --with-curl --with-mcrypt --with-openssl --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    && make && make install \
    && mkdir /etc/php \
    && cp /usr/src/php/php.ini-development /etc/php/php.ini \
    && cp /usr/src/php/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm && chmod +x /etc/init.d/php-fpm
WORKDIR /usr/local/php/etc
RUN cp php-fpm.conf.default php-fpm.conf \
    && sed -i "s/;daemonize = yes/daemonize = no/" php-fpm.conf \
    && cp ./php-fpm.d/www.conf.default ./php-fpm.d/www.conf \
    && sed -i "s/export PATH/PATH=\/usr\/local\/php\/bin:\$PATH\nexport PATH/" /etc/profile \
    && sed -i "s/export PATH/PATH=\/etc\/init.d:\$PATH\nexport PATH/" /etc/profile \
    && cp /usr/local/php/bin/php /usr/sbin/ \
    && cp /usr/local/php/bin/phpize /usr/sbin/

#安装nginx
WORKDIR /usr/src
RUN wget -O nginx.tar.gz http://nginx.org/download/nginx-${NGINX_VER}.tar.gz -O nginx.tar.gz && mkdir nginx && tar -zxvf nginx.tar.gz -C ./nginx --strip-components 1
WORKDIR nginx
RUN useradd $USER -s /sbin/nologin -M
RUN ./configure --prefix=/usr/local/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/lock/nginx.lock --user=$USER --group=$GROUP --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --http-client-body-temp-path=/tmp/nginx/client/ --http-proxy-temp-path=/tmp/nginx/proxy/ --http-fastcgi-temp-path=/tmp/nginx/fcgi/ --with-pcre --with-http_dav_module \
     && make && make install \
     && mkdir -p -m 777 /tmp/nginx \
     && echo "#!/bin/sh" > /etc/init.d/nginx \
     && echo "#description: Nginx web server." >> /etc/init.d/nginx \
     && echo -e "case \$1 in \n\
            restart): \n\
                /usr/local/nginx/sbin/nginx -s reload \n\
                ;; \n\
            stop): \n\
                /usr/local/nginx/sbin/nginx -s stop \n\
                ;; \n\
            *): \n\
                /usr/local/nginx/sbin/nginx \n\
                ;; \n\
        esac \n" >> /etc/init.d/nginx \
     && chmod +x /etc/init.d/nginx
RUN \
  cd /etc/nginx/ && mv nginx.conf nginx.conf.baks \
     && wget http://oxnd75eqj.bkt.clouddn.com/1515828324.conf \
     && mv 1515828324.conf nginx.conf && mkdir sites.d \
     && cd sites.d &&  wget http://oxnd75eqj.bkt.clouddn.com/1515839080.zip \
     && unzip 1515839080.zip && rm -rf 1515839080.zip \
     && cd /etc/nginx/ && mkdir rewrite && cd rewrite && touch test.conf

#安装redis server
WORKDIR /usr/src
RUN wget -O redis.tar.gz http://download.redis.io/releases/redis-${REDIS_VER}.tar.gz && mkdir redis && tar -xzvf redis.tar.gz -C ./redis --strip-components 1
WORKDIR /usr/src/redis
RUN make \
    && make install \
    && mkdir -p /usr/local/redis/bin \
    && cp ./src/redis-server /usr/local/redis/bin/ \
    && cp ./src/redis-cli /usr/local/redis/bin/ \
    && cp ./src/redis-benchmark /usr/local/redis/bin/ \
    && cp ./redis.conf /etc/redis.conf \
    && sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis.conf \
    && sed -i "s/# requirepass foobared/requirepass ${REDIS_PASS}/" /etc/redis.conf \
    && echo -e "# description: Redis server. \n\
         case \$1 in \n\
            restart): \n\
                /usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 6379 -a ${REDIS_PASS} shutdown \n\
                /usr/local/redis/bin/redis-server /etc/redis.conf \n\
                ;; \n\
            stop): \n\
                /usr/local/redis/bin/redis-cli -h 127.0.0.1 -p 6379 -a ${REDIS_PASS} shutdown \n\
                ;; \n\
            *): \n\
                /usr/local/redis/bin/redis-server /etc/redis.conf \n\
         esac" > /etc/init.d/redis \
    && chmod +x /etc/init.d/redis

WORKDIR /usr/src
#按照swoole
RUN git clone https://github.com/swoole/swoole-src.git && cd swoole-src \
&& phpize && ./configure --enable-async-redis  --enable-openssl && make clean && make -j \
&& make install

#安装php redis、mongodb扩展
RUN /usr/local/php/bin/pecl install redis && echo '[redis]' >> /etc/php/php.ini && echo "extension=redis.so" >> /etc/php/php.ini \
    && /usr/local/php/bin/pecl install swoole && echo '[swoole]' >> /etc/php/php.ini && echo "extension=swoole.so" >> /etc/php/php.ini \
    \
    && /usr/local/php/bin/pecl install mongodb && echo '[mongodb]' >> /etc/php/php.ini &&  echo "extension=mongodb.so" >> /etc/php/php.ini

WORKDIR /www

#安装必要的服务
RUN yum install vixie-cron crontabs -y \
     && cd /usr/src && /usr/local/php/bin/php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && /usr/local/php/bin/php composer-setup.php  --install-dir=/usr/local/bin --filename=composer && rm -rf composer-setup.php && cp /usr/local/bin/composer /usr/sbin/  \
     && composer config -g repo.packagist composer https://packagist.phpcomposer.com

WORKDIR /var/tools
RUN mkdir test && cd test && echo "<?php phpinfo(); ?>" > /var/tools/test/index.php  \
  && cd /var/tools \
  && wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash \
  && source ~/.bash_profile \
  && nvm install $NODE_VER && npm install -g cnpm --registry=https://registry.npm.taobao.org \
  && cnpm install --global gulp

#定时任务
RUN \
  cd /etc/cron.d  \
  && wget http://oxnd75eqj.bkt.clouddn.com/1515738502.zip \
  && unzip 1515738502.zip && rm -rf 1515738502.zip

WORKDIR /www
# 安装phpxhprof扩展
RUN git clone https://github.com/longxinH/xhprof.git && cd xhprof/extension/  \
    && phpize   \
    && ./configure --with-php-config=/usr/local/php/bin/php-config --enable-xhprof \
    && make && make install \
    && mkdir -p -m 777 /tmp/xhprof \
    && echo -e "[xhprof]\nextension = xhprof.so\nxhprof.output_dir = /tmp/xhprof" >> /etc/php/php.ini \
    && cd /www/xhprof \
#    && mkdir /var/tools && mv xhprof_html /var/tools/ \
    && mv xhprof_html /var/tools/ \
    && mv xhprof_lib /usr/local/php/lib/php \
    && sed -i "s/dirname(__FILE__) . '\/..\/xhprof_lib'/'xhprof_lib'/" /var/tools/xhprof_html/index.php \
    && sed -i "s/dirname(__FILE__) . '\/..\/xhprof_lib'/'xhprof_lib'/" /var/tools/xhprof_html/callgraph.php \
    && sed -i "s/dirname(__FILE__) . '\/..\/xhprof_lib'/'xhprof_lib'/" /var/tools/xhprof_html/typeahead.php \
    && rm -rf /www/xhprof


WORKDIR /www

#配置supervisor
RUN  source /etc/profile \
   \
    && echo [supervisord] >> /etc/supervisord.conf \
    && echo nodaemon=true >> /etc/supervisord.conf \
    \
    && echo [program:sshd] >> /etc/supervisord.conf \
    && echo command=/usr/sbin/sshd -D >> /etc/supervisord.conf \
    \
    && echo [program:nginx] >> /etc/supervisord.conf \
    && echo command=/etc/init.d/nginx start >> /etc/supervisord.conf \
    \
    && echo [program:php-fpm] >> /etc/supervisord.conf \
    && echo command=/etc/init.d/php-fpm start >> /etc/supervisord.conf \
    \
    && echo [program:redis] >> /etc/supervisord.conf \
    && echo command=/usr/local/redis/bin/redis-server /etc/redis.conf >> /etc/supervisord.conf \
    \
    && echo [program:crond] >> /etc/supervisord.conf \
    && echo startsecs=3 >> /etc/supervisord.conf \ 
    && echo command=/usr/sbin/crond -n -x bit >> /etc/supervisord.conf

RUN source /etc/profile
RUN chown -R www:www /www/


EXPOSE 22 80 11211 6379


CMD ["/usr/bin/supervisord"]
