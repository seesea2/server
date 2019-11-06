#!/bin/bash

printf "\n\n"
echo 'File: '$(basename "$0")
printf "\n"

source global.conf

myId=$(whoami)
if [[ "root" == $myId ]]; then
  myDirectory= "/root/"
else
  myDirectory="/home/${myId}"
fi

echo '================ install nodejs ================'
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo -s <<EOF
apt-get update >/dev/null
apt-get install -y nodejs

echo '================ install typescript, npm, pm2 ================'
npm i -g typescript
npm i -g npm
npm i -g pm2

if [[ -d ${myDirectory}/insg ]]; then
  rm ${myDirectory}/insg -R -f
fi

chown -R ${myId}: ${myDirectory}

env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u ${myId} --hp ${myDirectory} 
EOF

pm2 delete all

printf "\n"
echo '================ install nodejs website ================'
git clone https://github.com/seesea2/insg.git ${myDirectory}/insg

sudo su -c "ufw allow 8080"
npm install --prefix ${myDirectory}/insg
pm2 start "${myDirectory}/insg/dist/server.js"
pm2 save
