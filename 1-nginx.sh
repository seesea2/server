#!/bin/bash

printf "\n\n"
echo $(basename "$0")

source config.conf

echo Install and cofigure nginx
apt-get -y install nginx >/dev/null

{
  echo '  location ^~ /.well-known/acme-challenge/ {'
  echo "    allow all;"
  echo "    root /var/lib/letsencrypt/;"
  echo '    default_type "text/plain";'
  echo '    try_files $uri =404;'
  echo "  }"
} >/etc/nginx/snippets/letsencrypt.conf

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
sed -i 's/TLSv1 //' /etc/nginx/nginx.conf >/dev/null
sed -i 's/TLSv1.1 //' /etc/nginx/nginx.conf >/dev/null

ufw allow 'Nginx Full' >/dev/null
systemctl enable nginx >/dev/null
service nginx start >/dev/null
