#!/bin/bash
# Entry point for configuring the system.
#####################################################

export DEBIAN_FRONTEND=noninteractive

chmod +x ./*.sh >/dev/null
source config.conf

# upgrade os to latest
./0-os.sh

./mail.sh

./1-nginx.sh
./2-letsencrypt.sh

# source 3-mysql.sh
# source 4-postfixadmin.sh
# source 5-postfix.sh
# source 6-dovecot.sh

# ./10-nodejs.sh
