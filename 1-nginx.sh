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
  echo '    return 301 https://$host$request_uri;'
  echo "  } "
  echo "  server { "
  echo "    listen 443 ssl default_server;"
  echo "    listen [::]:443 default_server;"
  echo "    server_name ${myDomain};"
  # echo "    ssl_certificate         /etc/letsencrypt/live/${myDomain}/fullchain.pem;"
  # echo "    ssl_certificate_key     /etc/letsencrypt/live/${myDomain}/privkey.pem;"
  # echo "    ssl_trusted_certificate /etc/letsencrypt/live/${myDomain}/chain.pem;"
  echo "    include snippets/letsencrypt.conf;"
  echo "    location / {"
  echo "      proxy_pass http://localhost:8080;"
  echo "    }"
  echo "  }"
  echo "  server {"
  echo "    listen 443 ssl http2;"
  echo "    listen [::]:443 ssl http2;"
  echo "    server_name mail.${myDomain};"
  # echo "    ssl_certificate           /etc/letsencrypt/live/${myDomain}/fullchain.pem;"
  # echo "    ssl_certificate_key       /etc/letsencrypt/live/${myDomain}/privkey.pem;"
  # echo "    ssl_trusted_certificate   /etc/letsencrypt/live/${myDomain}/chain.pem;"
  echo "    root /var/www/roundcube;"
  echo "    index index.php;"
  echo "    location / {"
  echo '      try_files $uri $uri/ /index.php;'
  echo "    }"
  echo '    location ~* \.php$ {'
  echo '      fastcgi_split_path_info ^(.+?\.php)(/.*)$;'
  echo '      if (!-f $document_root$fastcgi_script_name) {return 404;}'
  echo "      fastcgi_pass  unix:/run/php/php7.2-fpm.sock;"
  echo "      fastcgi_index index.php;"
  echo "      include fastcgi_params;"
  echo '      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;'
  echo "    }"
  echo "  }"
  echo "  server {"
  echo "    listen 443 ssl http2;"
  echo "    listen [::]:443 ssl http2;"
  echo "    server_name pfa.${myDomain};"
  # echo "    ssl_certificate           /etc/letsencrypt/live/${myDomain}/fullchain.pem;"
  # echo "    ssl_certificate_key       /etc/letsencrypt/live/${myDomain}/privkey.pem;"
  # echo "    ssl_trusted_certificate   /etc/letsencrypt/live/${myDomain}/chain.pem;"
  echo "    root /var/www/postfixadmin;"
  echo "    index index.php;"
  echo "    location / {"
  echo '      try_files $uri $uri/ /index.php;'
  echo "    }"
  echo '    location ~* \.php$ {'
  echo '      fastcgi_split_path_info ^(.+?\.php)(/.*)$;'
  echo '      if (!-f $document_root$fastcgi_script_name) {return 404;}'
  echo '      fastcgi_pass  unix:/run/php/php7.2-fpm.sock;'
  echo "      fastcgi_index index.php;"
  echo "      include fastcgi_params;"
  echo '      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;'
  echo "    }"
  echo "  }"
} >/etc/nginx/sites-available/default

# disable SSL older than TLS1.2
sed -i 's/TLSv1 //' /etc/nginx/nginx.conf
sed -i 's/TLSv1.1 //' /etc/nginx/nginx.conf

service nginx restart >/dev/null
