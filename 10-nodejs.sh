#!/bin/bash

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo -s<<EOF 
apt-get update
apt-get -y install nodejs

npm i -g typescript
npm i -g npm
npm i -g pm2
EOF

su -c "chown -R yc: ~/"

pm2 startup
pm2 save

wget https://github.com/seesea2/insg.git

pm2 "insg/dist/server.js"
