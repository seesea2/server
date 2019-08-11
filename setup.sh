#!/bin/bash
# Entry point for configuring the system.
#####################################################

echo $(basename "$0")

# export DEBIAN_FRONTEND=noninteractive

chmod +x ./*.sh >/dev/null

# upgrade os to latest
sudo su -c ./0-os.sh

# install nginx and SSL/TLS
sudo su -c ./1-nginx.sh
sudo su -c ./2-letsencrypt.sh

# nodejs & server
./3-nodejs.sh

# mail server
sudo su -c ./4-mysql.sh
sudo su -c ./5-postfix.sh
sudo su -c ./6-dovecot.sh

sudo su -c ./7-postfixadmin.sh
sudo su -c ./8-roundcube.sh
