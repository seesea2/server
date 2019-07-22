#!/bin/bash
# Entry point for configuring the system.
#####################################################

echo "\n\n"$(basename "$0")

export DEBIAN_FRONTEND=noninteractive

chmod +x ./*.sh >/dev/null

# upgrade os to latest
./0-os.sh

./mail.sh

./1-nginx.sh
./2-letsencrypt.sh

./3-mysql.sh

# source 4-postfixadmin.sh
# source 5-postfix.sh
# source 6-dovecot.sh

# ./10-nodejs.sh
