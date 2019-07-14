#!/bin/bash

sudo apt install -y nginx

sudo systemctl enable nginx
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

sudo sed -i 's/TLSv1 //' /etc/nginx/nginx.conf
sudo sed -i 's/TLSv1.1 //' /etc/nginx/nginx.conf
    
sudo service nginx restart
    
    
    

