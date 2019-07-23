#!/bin/bash

printf "\n\n"
echo $(basename "$0")

curl -sL https://deb.nodesource.com/setup_10.x >/dev/null | sudo -E bash -
sudo -s<<EOF 
apt-get update >/dev/null
apt-get -y install nodejs

echo install typescript, npm, pm2
npm i -g typescript >/dev/null
npm i -g npm >/dev/null
npm i -g pm2 >/dev/null
EOF

su -c "chown -R yc: ~/"

pm2 startup
pm2 save

wget https://github.com/seesea2/insg.git

pm2 "insg/dist/server.js"
