#!/bin/bash

sudo apt -y install dovecot-imapd dovecot-mysql dovecot-managesieved dovecot-core
sudo service dovecot start

