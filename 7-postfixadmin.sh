#!/bin/bash

printf "\n\n"
echo '======================= File: '$(basename "$0")' ======================='
printf "\n"

source global.conf

printf "\n"
echo "======================= install postfixadmin ======================="
wget -q https://sourceforge.net/projects/postfixadmin/files/latest/download -O postfixadmin.tar.gz
tar xf postfixadmin.tar.gz >/dev/null
rm postfixadmin.tar.gz

printf "\n"
echo "======================= configure postfixadmin ======================="
if [[ -d '/var/www/postfixadmin' ]]; then
  rm -R /var/www/html/postfixadmin
fi
cp -f -R postfixadmin-*/ /var/www/html/postfixadmin
rm -R postfixadmin-*/

cat >/var/www/html/postfixadmin/config.local.php <<EOF
<?php
  \$CONF['database_type'] = 'mysqli';
  \$CONF['database_user'] = '${myDbUser}';
  \$CONF['database_host'] = 'localhost';
  \$CONF['database_password'] = '${myDbPass}';
  \$CONF['database_name'] = '${myDb}';

  \$CONF['configured'] = true;
?>
EOF

mkdir -p /var/www/html/postfixadmin/templates_c
chmod 755 -R /var/www/html/postfixadmin/templates_c
chown -R www-data: /var/www

{
  echo "  server {"
  echo "    listen 443 ssl http2;"
  echo "    listen [::]:443 ssl http2;"
  echo "    server_name pfa.${myDomain};"
  echo "    ssl_certificate           /etc/letsencrypt/live/${myDomain}/fullchain.pem;"
  echo "    ssl_certificate_key       /etc/letsencrypt/live/${myDomain}/privkey.pem;"
  echo "    ssl_trusted_certificate   /etc/letsencrypt/live/${myDomain}/chain.pem;"
  echo "    root /var/www/html/postfixadmin/public;"
  echo "    index index.php;"
  echo "    location / {"
  echo '      try_files $uri $uri/ /index.php;'
  echo '    }'
  echo '    location ~* \.php$ {'
  echo '      fastcgi_split_path_info ^(.+?\.php)(/.*)$;'
  echo '      if (!-f $document_root$fastcgi_script_name) {return 404;}'
  echo '      include snippets/fastcgi-php.conf;'
  echo '      fastcgi_pass  unix:/run/php/php7.2-fpm.sock;'
  echo "      include fastcgi_params;"
  echo '      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;'
  echo "    }"
  echo "  }"
} >>/etc/nginx/sites-available/default

service nginx reload

# then, please set up at:  pfa.web.com/setup.php
