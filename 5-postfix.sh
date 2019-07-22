#!/bin/bash

source config.conf

sudo apt -y install php-imap php-mbstring # php7.2-imap php7.2-mbstring
debconf-set-selections <<< "postfix postfix/mailname string $myDomain"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt -y install postfix postfix-mysql
sudo service postfix start

sudo postconf -e "myhostname = ${myHost}.${myDomain}"
sudo postconf -e "mydomain = ${myDomain}"
sudo postconf -e "myorigin = $mydomain"
sudo postconf -e "mydestination = localhost"
sudo postconf -e "inet_interfaces = all"
sudo postconf -e "inet_protocols = all"

IFS=""

sudo mkdir -p /etc/postfix/sql
sudo cat >/etc/postfix/sql/mysql_virtual_domains_maps.cf <<EOF
user = ${mysqlUser}
password = ${mysqlPass}
hosts = 127.0.0.1
dbname = ${mysqlDb}
query = SELECT domain FROM domain WHERE domain='%s' AND active = '1'
EOF
sudo postconf -e virtual_mailbox_domains=mysql:/etc/postfix/sql/mysql_virtual_domains_maps.cf

sudo cat >/etc/postfix/sql/mysql_virtual_mailbox_maps.cf <<EOF
user = ${mysqlUser}
password =  ${mysqlPass}
hosts = 127.0.0.1
dbname =  ${mysqlDb}
query = SELECT maildir FROM mailbox WHERE username='%s' AND active = '1'
EOF
sudo postconf -e virtual_mailbox_maps=mysql:/etc/postfix/sql/mysql_virtual_mailbox_maps.cf

sudo cat >/etc/postfix/sql/mysql_virtual_alias_maps.cf <<EOF
user = ${mysqlUser}
password = ${mysqlPass}
hosts = 127.0.0.1
dbname = ${mysqlDb}
query = SELECT goto FROM alias WHERE address='%s' AND active = '1'
EOF
sudo postconf -e virtual_alias_maps=mysql:/etc/postfix/sql/mysql_virtual_alias_maps.cf

sudo postconf -e smtpd_sasl_type=dovecot
sudo postconf -e smtpd_sasl_path = private/auth
sudo postconf -e smtpd_sasl_auth_enable = yes
sudo postconf -e smtpd_sasl_security_options = noanonymous
sudo postconf -e smtpd_tls_security_level = may
sudo postconf -e smtpd_tls_auth_only = yes

sudo postconf -e "virtual_transport = lmtp:unix:private/dovecot-lmtp"

sudo postconf -e 'smtp_tls_security_level = may'
sudo postconf -e 'smtp_tls_note_starttls_offer = yes'
sudo postconf -e 'smtpd_tls_loglevel = 1'
sudo postconf -e 'smtpd_tls_received_header = yes'
sudo postconf -e 'smtpd_tls_cert_file = /etc/letsencrypt/live/${myDomain}/fullchain.pem'
sudo postconf -e 'smtpd_tls_key_file = /etc/letsencrypt/live/${myDomain}/privkey.pem'

sudo postconf -e 'smtpd_sasl_local_domain ='
sudo postconf -e 'broken_sasl_auth_clients = yes'
sudo postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'


#master.cf config
sudo postconf -M submission/inet="submission       inet       n       -       -       -       -       smtpd"
sudo postconf -P submission/inet/syslog_name=postfix/submission
sudo postconf -P submission/inet/smtpd_tls_security_level=encrypt
sudo postconf -P submission/inet/smtpd_sasl_auth_enable=yes
sudo postconf -P submission/inet/smtpd_sasl_auth_type=dovecot
sudo postconf -P submission/inet/smtpd_sasl_auth_path=private/auth
sudo postconf -P submission/inet/smtpd_client_restrictions=permit_sasl_authenticated,reject

sudo service postfix restart
