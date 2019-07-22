#!/bin/bash

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt update
sudo apt -y install nodejs

sudo npm i -g typescript
sudo npm i -g npm
sudo npm i -g pm2

sudo chown -R yc: ~/

pm2 startup
pm2 save
