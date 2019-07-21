#!/bin/bash
# Entry point for configuring the system.
#####################################################

chmod +x ./*.sh
source config.conf
cat <config.conf

# upgrade os to latest
source 0-os.sh

source mail.sh

source 1-nginx.sh
source 2-letsencrypt.sh
source 3-mysql.sh
source 4-postfixadmin.sh
source 5-postfix.sh
source 6-dovecot.sh

./10-nodejs.sh
