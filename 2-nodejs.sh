#!/bin/bash

#curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
#sudo apt update
#sudo apt install -y nodejs

mkdir ~/.node
echo "prefix = ~/.node" > ~/.npmrc

cat >> ~/.profile <<EOF
	PATH="$HOME/.node/bin:$PATH"
	NODE_PATH="$HOME/.node/lib/node_modules:$NODE_PATH"
	MANPATH="$HOME/.node/share/man:$MANPATH"
EOF


sudo npm i -g typescript
sudo npm i -g pm2

sudo chown -R yc: ~/


pm2 startup
pm2 save


