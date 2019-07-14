#!/bin/bash

sudo apt install -y certbot

sudo mkdir -p /var/lib/letsencrypt/.well-known
sudo chgrp www-data /var/lib/letsencrypt
sudo chmod g+s /var/lib/letsencrypt

sudo cat > /etc/nginx/snippets/well-known.conf <<EOF
	location ^~ /.well-known/ace-challenge/ {
		allow all;
		root /var/lib/letsencrypt/;
		default_type "text/plain";
		try_files $uri =404;
	}
EOF

nginx -t
sudo service nginx reload

certbot certonly --agree-tos --email yc@insg.xyz --webroot -w /var/lib/letsencrypt/ -d insg.xyz -d *.insg.xyz





