#!/bin/bash

printf "\n\n"
echo $(basename "$0")

source config.conf

echo install php-imap, php-mbstring
apt-get -y install php-imap php-mbstring >/dev/null # php7.2-imap php7.2-mbstring
debconf-set-selections <<< "postfix postfix/mailname string $myDomain"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

echo install postfix, postfix-mysql
apt-get -y install postfix postfix-mysql
service postfix start

postconf -e "myhostname = ${myHost}.${myDomain}"
postconf -e "mydomain = ${myDomain}"
postconf -e "myorigin = $mydomain"
postconf -e "mydestination = localhost"
postconf -e "inet_interfaces = all"
postconf -e "inet_protocols = all"

IFS=""

mkdir -p /etc/postfix/sql
cat >/etc/postfix/sql/mysql_virtual_domains_maps.cf <<EOF
user = ${myDbUser}
password = ${myDbPass}
hosts = 127.0.0.1
dbname = ${myDb}
query = SELECT domain FROM domain WHERE domain='%s' AND active = '1'
EOF
postconf -e "virtual_mailbox_domains = mysql:/etc/postfix/sql/mysql_virtual_domains_maps.cf"

cat >/etc/postfix/sql/mysql_virtual_mailbox_maps.cf <<EOF
user = ${myDbUser}
password =  ${myDbPass}
hosts = 127.0.0.1
dbname =  ${myDb}
query = SELECT maildir FROM mailbox WHERE username='%s' AND active = '1'
EOF
postconf -e "virtual_mailbox_maps = mysql:/etc/postfix/sql/mysql_virtual_mailbox_maps.cf"

cat >/etc/postfix/sql/mysql_virtual_alias_maps.cf <<EOF
user = ${myDbUser}
password = ${myDbPass}
hosts = 127.0.0.1
dbname = ${myDb}
query = SELECT goto FROM alias WHERE address='%s' AND active= '1'
EOF
postconf -e "virtual_alias_maps = mysql:/etc/postfix/sql/mysql_virtual_alias_maps.cf"

postconf -e "smtpd_sasl_type = dovecot"
postconf -e "smtpd_sasl_path = private/auth"
postconf -e "smtpd_sasl_auth_enable = yes"
 postconf -e "smtpd_sasl_security_options = noanonymous"
 postconf -e "smtpd_tls_security_level = may"
 postconf -e "smtpd_tls_auth_only = yes"

 postconf -e "virtual_transport = lmtp:unix:private/dovecot-lmtp"

 postconf -e 'smtp_tls_security_level = may'
 postconf -e 'smtp_tls_note_starttls_offer = yes'
 postconf -e 'smtpd_tls_loglevel = 1'
 postconf -e 'smtpd_tls_received_header = yes'
 postconf -e 'smtpd_tls_cert_file = /etc/letsencrypt/live/${myDomain}/fullchain.pem'
 postconf -e 'smtpd_tls_key_file = /etc/letsencrypt/live/${myDomain}/privkey.pem'

 postconf -e 'smtpd_sasl_local_domain = '
 postconf -e 'broken_sasl_auth_clients = yes'
 postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'


#master.cf config
 postconf -M submission/inet="submission       inet       n       -       -       -       -       smtpd"
 postconf -P submission/inet/syslog_name=postfix/submission
 postconf -P submission/inet/smtpd_tls_security_level=encrypt
 postconf -P submission/inet/smtpd_sasl_auth_enable=yes
 postconf -P submission/inet/smtpd_sasl_auth_type=dovecot
 postconf -P submission/inet/smtpd_sasl_auth_path=private/auth
 postconf -P submission/inet/smtpd_client_restrictions=permit_sasl_authenticated,reject
 
 ufw allow Postfix
 ufw allow "Postfix SMTPS"
 ufw allow "Postfix Submission"

 service postfix restart

