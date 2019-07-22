#!/bin/bash

source config.conf

apt-get -y install nginx

systemctl enable nginx
ufw allow 'Nginx Full'

nginxConf = "
  server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

  include snippets/letsencrypt.conf;

    return 301 https://$host$request_uri;
  }
    
  server {
    listen 443 ssl default_server;
    listen [::]:443 default_server;
    server_name ${myDomain};

    ssl_certificate           /etc/letsencrypt/live/${myDomain}/fullchain.pem; 
    ssl_certificate_key       /etc/letsencrypt/live/${myDomain}/privkey.pem; 
    ssl_trusted_certificate   /etc/letsencrypt/live/${myDomain}/chain.pem; 

  include snippets/letsencrypt.conf;
    location / {
      proxy_pass http://localhost:8080;
    }
  }

  server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name mail.${myDomain};

    ssl_certificate           /etc/letsencrypt/live/${myDomain}/fullchain.pem; 
    ssl_certificate_key       /etc/letsencrypt/live/${myDomain}/privkey.pem; 
    ssl_trusted_certificate   /etc/letsencrypt/live/${myDomain}/chain.pem; 

    root /var/www/roundcube;
    index index.php;

    location / {
      try_files $uri $uri/ /index.php;
    }
    location ~* \.php$ {
      fastcgi_split_path_info ^(.+?\.php)(/.*)$;
      if (!-f $document_root$fastcgi_script_name) {return 404;}
      fastcgi_pass  unix:/run/php/php7.2-fpm.sock;
      fastcgi_index index.php;
      include fastcgi_params;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
  }

  server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name pfa.${myDomain};

    ssl_certificate           /etc/letsencrypt/live/${myDomain}/fullchain.pem; 
    ssl_certificate_key       /etc/letsencrypt/live/${myDomain}/privkey.pem; 
    ssl_trusted_certificate   /etc/letsencrypt/live/${myDomain}/chain.pem; 

    root /var/www/postfixadmin;
    index index.php;

    location / {
      try_files $uri $uri/ /index.php;
    }
    location ~* \.php$ {
      fastcgi_split_path_info ^(.+?\.php)(/.*)$;
      if (!-f $document_root$fastcgi_script_name) {return 404;}
      fastcgi_pass  unix:/run/php/php7.2-fpm.sock;
      fastcgi_index index.php;
      include fastcgi_params;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
  }
"
cat $nginxConf >/etc/nginx/sites-available/default 

# disable SSL older than TLS1.2
sed -i 's/TLSv1 //' /etc/nginx/nginx.conf
sed -i 's/TLSv1.1 //' /etc/nginx/nginx.conf

service nginx restart
