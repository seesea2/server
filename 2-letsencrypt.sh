#!/bin/bash

echo "\n\n"$(basename "$0")

source config.conf

apt-get -y install certbot python-certbot-nginx >/dev/null

rm -R /var/lib/letsencrypt
mkdir -p /var/lib/letsencrypt/.well-known
chgrp www-data /var/lib/letsencrypt
chmod g+s /var/lib/letsencrypt

certbot certonly --agree-tos --email yc@insg.xyz --webroot -w /var/lib/letsencrypt/ -d www.${myDomain} -d ${myDomain} -d mail.${myDomain} -d pfa.${myDomain} >/dev/null

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
  echo "    ssl_certificate         /etc/letsencrypt/live/${myDomain}/fullchain.pem;"
  echo "    ssl_certificate_key     /etc/letsencrypt/live/${myDomain}/privkey.pem;"
  echo "    ssl_trusted_certificate /etc/letsencrypt/live/${myDomain}/chain.pem;"
  echo "    include snippets/letsencrypt.conf;"
  echo "    location / {"
  echo "      proxy_pass http://localhost:8080;"
  echo "    }"
  echo "  }"
  echo "  server {"
  echo "    listen 443 ssl http2;"
  echo "    listen [::]:443 ssl http2;"
  echo "    server_name mail.${myDomain};"
  echo "    ssl_certificate           /etc/letsencrypt/live/${myDomain}/fullchain.pem;"
  echo "    ssl_certificate_key       /etc/letsencrypt/live/${myDomain}/privkey.pem;"
  echo "    ssl_trusted_certificate   /etc/letsencrypt/live/${myDomain}/chain.pem;"
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
  echo "    ssl_certificate           /etc/letsencrypt/live/${myDomain}/fullchain.pem;"
  echo "    ssl_certificate_key       /etc/letsencrypt/live/${myDomain}/privkey.pem;"
  echo "    ssl_trusted_certificate   /etc/letsencrypt/live/${myDomain}/chain.pem;"
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

nginx -t
service nginx reload >/dev/null

# update-ca-certificates
