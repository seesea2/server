#!/bin/bash

source config.conf

apt -y install certbot

mkdir -p /var/lib/letsencrypt/.well-known
chgrp www-data /var/lib/letsencrypt
chmod g+s /var/lib/letsencrypt

myString = '
  location ^~ /.well-known/acme-challenge/ {
    allow all;
    root /var/lib/letsencrypt/;
    default_type "text/plain";
    try_files $uri =404;
  }
'
cat $myString >/etc/nginx/snippets/letsencrypt.conf

nginx -t
service nginx reload

# certbot certonly --agree-tos --email yc@insg.xyz --webroot -w /var/lib/letsencrypt/ -d ${myDomain} -d *.${myDomain}

# update-ca-certificates
