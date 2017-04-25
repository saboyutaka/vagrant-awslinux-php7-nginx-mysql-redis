# #!/usr/bin/env bash

yum update
yum install -y git

# ssh passwordでログイン
sed -i -e 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
/etc/init.d/sshd restart

# install nginx
yum install nginx -y
mv /home/vagrant/nginx.conf /etc/nginx/nginx.conf
mv /home/vagrant/app.conf /etc/nginx/conf.d/app.conf
service nginx restart
chkconfig nginx on

# install php7.1
yum install -y http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum-config-manager --enable epel
yum install -y --disablerepo=amzn-main libwebp
yum install -y httpd libXpm gd-last libtool-ltdl automake
yum install -y --disablerepo=amzn-main --enablerepo=epel --enablerepo=remi-php71 php php-mysqlnd php-mbstring php-mcrypt php-pdo php-xml php-gd php-pear php-fpm php-devel
pecl install xdebug

cat >> /etc/php.ini <<EOS
zend_extension=/usr/lib64/php/modules/xdebug.so
; see http://xdebug.org/docs/all_settings
html_errors=on
xdebug.collect_vars=on
xdebug.collect_params=4
xdebug.dump_globals=on
xdebug.dump.GET=*
xdebug.dump.POST=*
xdebug.show_local_vars=on
xdebug.remote_enable = on
xdebug.remote_autostart=on
xdebug.remote_handler = dbgp
xdebug.remote_connect_back=on
xdebug.profiler_enable=0
xdebug.profiler_output_dir="/vagrant/www/tmp/profile"
xdebug.max_nesting_level=1000
xdebug.remote_host=192.168.100.1
xdebug.remote_port = 9001
xdebug.idekey = "mydebug"
EOS

sed -i -e 's/^listen\ =/;listen\ =/' /etc/php-fpm.d/www.conf
cat >> /etc/php-fpm.d/www.conf << EOS
listen = /var/run/php-fpm/php-fpm.sock
listen.owner = nginx
listen.group = nginx
EOS
service php-fpm restart
chkconfig php-fpm on

# install composer
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

# install mysql
yum install  mysql56 mysql56-server
sed -i -e 's/^socket/# socket/' /etc/my.cnf
cat >> /etc/my.cnf << EOS
[client]
default-character-set = utf8mb4

[mysql]
default-character-set=utf8mb4

[mysqld]
skip-character-set-client-handshake
character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci
init-connect          = SET NAMES utf8mb4
socket = /var/run/mysqld/mysqld.sock
EOS
service mysqld restart
chkconfig mysqld on

# install redis
yum install -y --enablerepo=remi redis
service redis start
chkconfig redis on
