#!/bin/bash

# create new user: vmail
if ! id -u vmail >/dev/null 2>&1; then
    sudo groupadd -g 5000 vmail && mkdir -p /var/mail/vmail
    sudo useradd -u 5000 vmail -g vmail -s /usr/sbin/nologin -d /var/mail/vmail
    sudo chown -R vmail: /etc/mail/vmail
fi
