#!/bin/bash

source config.conf

# set timezone
if [[ -f /usr/share/zoneinfo/${myTimeZone} ]]; then
    sudo echo ${myTimeZone} >/etc/timezone
    sudo dpkg-reconfigure -f noninteractive tzdata >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Timezone configuration failed."
        exit 1
    fi
    sudo restart_service rsyslog
fi

# set hostname
sudo echo ${myHost} >/etc/hostname
sudo hostname ${myHost}

sudo echo "${myHost}.${myDomain}" >/etc/mailname

# upgrade OS and install basic tools
echo upgrade OS and install basic tools
sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove >/dev/null
sudo apt-get -y install git curl wget

# Allow apt to install system updates automatically.
sudo cat >/etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::MaxAge "7";
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Verbose "0";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF

# disable logon welcome messages
sudo chmod -x /etc/update-motd.d/*

# firewall
sudo ufw_allow ssh
sudo ufw enable
