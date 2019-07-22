#!/bin/bash

source config.conf

apt -y install certbot >/dev/null

mkdir -p /var/lib/letsencrypt/.well-known
chgrp www-data /var/lib/letsencrypt
chmod g+s /var/lib/letsencrypt

{
  echo '  location ^~ /.well-known/acme-challenge/ {'
  echo "    allow all;"
  echo "    root /var/lib/letsencrypt/;"
  echo '    default_type "text/plain";'
  echo '    try_files $uri =404;'
  echo "  }"
} >/etc/nginx/snippets/letsencrypt.conf

certbot certonly --agree-tos --email yc@insg.xyz --webroot -w /var/lib/letsencrypt/ -d ${myDomain} -d *.${myDomain}

nginx -t
service nginx reload

# update-ca-certificates
