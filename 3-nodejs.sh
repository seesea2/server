#!/bin/bash

printf "\n\n"
echo 'File: '$(basename "$0")

source global.conf

myId=$(whoami)
if [[ "root" == $myId ]]; then
  myDirectory= "/root/"
else
  myDirectory="/home/${myId}"
fi

echo ================ install nodejs ================
curl -sL https://deb.nodesource.com/setup_12.x >/dev/null | sudo -E bash - >/dev/null
sudo -s <<EOF
apt-get update >/dev/null
apt-get -y install nodejs

echo '================ install typescript, npm, pm2 ================'
npm i -g typescript
npm i -g npm
npm i -g pm2

if [[ -d ${myDirectory}/insg ]]; then
  rm ${myDirectory}/insg -R
fi

chown -R ${myId}: ${myDirectory}

env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u ${myId} --hp ${myDirectory} 
EOF

pm2 delete all

echo
echo ================ install nodejs website ================
git clone https://github.com/seesea2/insg.git ${myDirectory}/insg

sudo su -c "ufw allow 8080"
npm install --prefix ${myDirectory}/insg
pm2 start "${myDirectory}/insg/dist/server.js"
pm2 save
