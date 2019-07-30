#!/bin/bash

printf "\n\n"
echo 'File: '$(basename "$0")

source global.conf

myId=$(whoami)
if [[ "root" == $myId ]]; then
  myDirectory = "/root/"
else
  myDirectory="/home/${myId}"
fi

echo ================ install nodejs ================
sudo -s <<EOF
curl -sL https://deb.nodesource.com/setup_12.x >/dev/null | sudo -E bash - >/dev/null
apt-get update >/dev/null
apt-get -y install nodejs

echo '================ install typescript, npm, pm2 ================'
npm i -g typescript >/dev/null
npm i -g npm >/dev/null
npm i -g pm2 >/dev/null
chown -R ${myId}: ${myDirectory}

rm ${myDirectory}/insg -R

EOF

sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u ${myId} --hp ${myDirectory}
pm2 delete all

echo
echo ================ install nodejs website ================
git clone https://github.com/seesea2/insg.git ${myDirectory}/insg

sudo su -c "ufw allow 8080"
npm install --prefix ${myDirectory}/insg
pm2 start "${myDirectory}/insg/dist/server.js"
pm2 save
