#!/bin/bash

printf "\n\n"
echo '======================= File: '$(basename "$0")' ======================='
printf "\n"

source global.conf

wget -q https://github.com/roundcube/roundcubemail/releases/download/1.3.9/roundcubemail-1.3.9-complete.tar.gz -O roundcube.tar.gz
tar -xf roundcube.tar.gz
rm roundcube.tar.gz

printf "\n"
echo "======================= configure roundcube ======================="
if [[ -d '/var/www/html/roundcube' ]]; then
  rm -R /var/www/html/roundcube
fi
mv roundcube*/ /var/www/html/roundcube
chown -R www-data: /var/www
chmod 755 /var/www/html/roundcube/temp/ /var/www/html/roundcube/logs/

{
  echo "  server {"
  echo "    listen 443 ssl http2;"
  echo "    listen [::]:443 ssl http2;"
  echo "    server_name mail.${myDomain};"
  echo "    ssl_certificate           /etc/letsencrypt/live/${myDomain}/fullchain.pem;"
  echo "    ssl_certificate_key       /etc/letsencrypt/live/${myDomain}/privkey.pem;"
  echo "    ssl_trusted_certificate   /etc/letsencrypt/live/${myDomain}/chain.pem;"
  echo "    root /var/www/html/roundcube;"
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

service nginx reload

# then setup at: mail.site.com/installer
# IMAP ssl://mail.site.com   port 993
# SMTP ssl://mail.site.com port 465
