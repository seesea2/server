#!/bin/bash

echo ""
echo '======================= File: '$(basename "$0")' ======================='

source global.conf

echo ""
echo "======================= configure roundcube ======================="
{
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
} >>/etc/nginx/sites-available/default
