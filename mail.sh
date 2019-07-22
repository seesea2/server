#!/bin/bash

# create new user: vmail
if ! id -u vmail >/dev/null 2>&1; then
    groupadd -g 5000 vmail
    useradd -u 5000 vmail -g vmail -s /usr/sbin/nologin -d /var/mail
    chown -R vmail: /etc/mail
fi
