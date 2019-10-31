#!/bin/bash

printf "\n\n"
echo '================= File: '$(basename "$0")' ================='
printf "\n"

source global.conf

echo '================= Install and cofigure nginx ================='
apt-get -y install nginx php php-fpm php-curl php-xml php-gd php-intl php-ldap php-imagick php-mysql php-imap php-mbstring

{
  echo "  server { "
  echo "    listen 80 default_server;"
  echo "    listen [::]:80 default_server;"
  echo "    server_name _;"
  echo "    root /var/www/html;"
  echo "    index index.html index.nginx-debian.html;"
  echo "  } "
} >/etc/nginx/sites-available/default

printf "\n"
echo '================= cofigure php7.2-fpm ================='
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' "/etc/php/7.2/fpm/php.ini"
sed -i 's/;date.timezone =/date.timezone = Asia\/Singapore/' "/etc/php/7.2/fpm/php.ini"
systemctl restart php7.2-fpm

printf "\n"
echo '================= disable TLSv1 TLSv1.1 ================='
# disable SSL older than TLS1.2
sed -i 's/TLSv1 //' /etc/nginx/nginx.conf
sed -i 's/TLSv1.1 //' /etc/nginx/nginx.conf

printf "\n"
ufw allow 'Nginx Full'

systemctl enable nginx
service nginx start
