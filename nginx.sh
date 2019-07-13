#!/bin/bash

sudo apt install nginx -y

sudo systemctl enable nginx
sudo service nginx start
sudo ufw allow 'Nginx HTTP'

sudo > /etc/nginx/sites-available/default

echo<EOF
    server {
        listen 80 default_server;
        
        server_name _;
        
        return 301 https://$host$request_uri;
    }
    
    server {
        listen 443 http2

        server_name _;
    }
EOF
    
    
    
    

