#!/bin/bash

printf "\n\n"
echo '======================== File: '$(basename "$0")' ========================'

source global.conf

echo ""
echo "================ install certbox ================"
apt-get -y install certbot python-certbot-nginx

if [[ -d "/var/lib/letencrypt" ]]; then
  rm -R /var/lib/letsencrypt
fi
mkdir -p /var/lib/letsencrypt/.well-known
chgrp www-data /var/lib/letsencrypt
chmod g+s /var/lib/letsencrypt

echo ""
echo "================ update nginx configuration ================" 
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
  echo "    index index.html index.nginx-debian.html;"
  echo "  } "
} >/etc/nginx/sites-available/default

service nginx reload

if [[ "1" == "$myGetTLS" ]]; then
  certbot certonly --agree-tos --email yc@insg.xyz --eff-email --webroot -w /var/lib/letsencrypt/ -d "${myDomain}" -d "www.${myDomain}" -d "mail.${myDomain}" -d "pfa.${myDomain}"
fi

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
    echo "    server_name ${myDomain} www.${myDomain};"
    echo "    ssl_certificate         /etc/letsencrypt/live/${myDomain}/fullchain.pem;"
    echo "    ssl_certificate_key     /etc/letsencrypt/live/${myDomain}/privkey.pem;"
    echo "    ssl_trusted_certificate /etc/letsencrypt/live/${myDomain}/chain.pem;"
    echo "    include snippets/letsencrypt.conf;"
    echo "    location / {"
    echo "      proxy_pass http://localhost:8080;"
    echo "    }"
    echo "  }"
  } >/etc/nginx/sites-available/default

echo test ================ nginx ================
nginx -t
service nginx restart

# update-ca-certificates
