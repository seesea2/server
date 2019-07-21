#!/bin/bash
# Entry point for configuring the system.
#####################################################

chmod +x ./*.sh

# upgrade os to latest
source 0-os.sh

source config.conf
source mail.sh


myDomain = insg.tk
# ./1-nginx.sh

./2-nodejs.sh

# ./10-letsencrypt.sh

# ./90-os-welcome.sh
