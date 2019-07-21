#!/bin/bash

source config.conf

sudo apt -y install certbot

sudo mkdir -p /var/lib/letsencrypt/.well-known
sudo chgrp www-data /var/lib/letsencrypt
sudo chmod g+s /var/lib/letsencrypt

sudo cat >/etc/nginx/snippets/well-known.conf <<EOF
  location ^~ /.well-known/acme-challenge/ {
    allow all;
    root /var/lib/letsencrypt/;
    default_type "text/plain";
    try_files $uri =404;
  }

  ssl_certificate           /etc/letsencrypt/live/${myDomain}/fullchain.pem; 
  ssl_certificate_key       /etc/letsencrypt/live/${myDomain}/privkey.pem; 
  ssl_trusted_certificate   /etc/letsencrypt/live/${myDomain}/chain.pem; 
EOF

nginx -t
sudo service nginx reload

sudo certbot certonly --agree-tos --email yc@insg.xyz --webroot -w /var/lib/letsencrypt/ -d ${myDomain} -d *.${myDomain}

# update-ca-certificates
