#!/bin/bash

printf "\n\n"
echo $(basename "$0")

source config.conf

myDirectory=/home/${myId}

#curl -sL https://deb.nodesource.com/setup_10.x >/dev/null | sudo -E bash - >/dev/null
sudo -s<<EOF 
apt-get update >/dev/null
apt-get -y install nodejs >/dev/null

echo install typescript, npm, pm2
echo npm i -g typescript >/dev/null
echo npm i -g npm >/dev/null
echo npm i -g pm2 >/dev/null
chown -R yc: ${myDirectory}
EOF



pm2 startup
pm2 save

cd ~
git clone https://github.com/seesea2/insg.git ${myDirectory}

su -c "ufw allow 8080"
npm install --prefix ${myDirectory}/insg
pm2 start "insg/dist/server.js"

