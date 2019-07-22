#!/bin/bash

printf "\n\n"
echo "\n\n"$(basename "$0")

source config.conf

# set timezone
if [[ -f /usr/share/zoneinfo/${myTimeZone} ]]; then
    echo ${myTimeZone} >/etc/timezone
    dpkg-reconfigure -f noninteractive tzdata >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Timezone configuration failed."
        exit 1
    fi
    service syslog restart
fi

# set hostname
echo ${myHost} >/etc/hostname
hostname ${myHost}

echo "${myHost}.${myDomain}" >/etc/mailname

# upgrade OS and install basic tools
echo upgrade OS and install basic tools
apt-get update >/dev/null && apt-get -y upgrade >/dev/null && apt-get -y autoremove >/dev/null
apt-get -y install git curl wget >/dev/null

# Allow apt to install system updates automatically.
cat >/etc/apt/apt.conf.d/20auto-upgrades <<EOF
    APT::Periodic::MaxAge "7";
    APT::Periodic::Update-Package-Lists "1";
    APT::Periodic::Unattended-Upgrade "1";
    APT::Periodic::Verbose "0";
    APT::Periodic::Download-Upgradeable-Packages "1";
    APT::Periodic::AutocleanInterval "7";
EOF

# disable logon welcome messages
chmod -x /etc/update-motd.d/* >/dev/null

# firewall
ufw allow ssh >/dev/null
ufw --force enable

# create new user: vmail
if ! id -u vmail >/dev/null 2>&1; then
    groupadd -g 5000 vmail
    useradd -u 5000 vmail -g vmail -s /usr/sbin/nologin -d /var/mail
    chown -R vmail: /etc/mail
fi
