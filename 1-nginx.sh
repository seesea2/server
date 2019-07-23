#!/bin/bash

printf "\n\n"
echo $(basename "$0")

source global.conf

echo Install and cofigure nginx
apt-get -y install nginx php php-fpm php-mysql >/dev/null

{
  echo "  server { "
  echo "    listen 80 default_server;"
  echo "    listen [::]:80 default_server;"
  echo "    server_name _;"
  echo "    root /var/www/html;"
  echo "    index index.html index.nginx-debian.html;"
  echo "  } "
} >/etc/nginx/sites-available/default

sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' "/etc/php/7.2/fpm/php.ini"
sed -i 's/;date.timezoneo =/date.timezone = Asia\/Singapore/' "/etc/php/7.2/fpm/php.ini"
systemctl restart php7.2-fpm

# disable SSL older than TLS1.2
sed -i 's/TLSv1 //' /etc/nginx/nginx.conf >/dev/null
sed -i 's/TLSv1.1 //' /etc/nginx/nginx.conf >/dev/null

ufw allow 'Nginx Full' >/dev/null
systemctl enable nginx >/dev/null
service nginx start >/dev/null
