#!/bin/bash

source config.conf

echo Install and cofigure nginx
apt-get -y install nginx >/dev/null

systemctl enable nginx >/dev/null
ufw allow 'Nginx Full' >/dev/null

>/etc/nginx/snippets/letsencrypt.conf

{
  echo "  server { "
  echo "    listen 80 default_server;"
  echo "    listen [::]:80 default_server;"
  echo "    server_name _;"
  echo "    include snippets/letsencrypt.conf;"
  echo "    root /var/www/html;"
  echo "  } "
} >/etc/nginx/sites-available/default

# disable SSL older than TLS1.2
sed -i 's/TLSv1 //' /etc/nginx/nginx.conf
sed -i 's/TLSv1.1 //' /etc/nginx/nginx.conf

service nginx restart >/dev/null
