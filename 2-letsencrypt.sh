#!/bin/bash

source config.conf

sudo apt -y install certbot

sudo mkdir -p /var/lib/letsencrypt/.well-known
sudo chgrp www-data /var/lib/letsencrypt
sudo chmod g+s /var/lib/letsencrypt

sudo cat >/etc/nginx/snippets/letsencrypt.conf <<EOF
  location ^~ /.well-known/acme-challenge/ {
    allow all;
    root /var/lib/letsencrypt/;
    default_type "text/plain";
    try_files \$uri =404;
  }

EOF

nginx -t
sudo service nginx reload

#sudo certbot certonly --agree-tos --email yc@insg.xyz --webroot -w /var/lib/letsencrypt/ -d ${myDomain} -d *.${myDomain}

# update-ca-certificates
