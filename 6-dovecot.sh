#!/bin/bash

sudo apt -y install dovecot-imapd dovecot-mysql dovecot-lmtpd dovecot-managesieved dovecot-core
sudo service dovecot start

