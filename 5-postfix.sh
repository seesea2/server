q   q           #!/bin/bash

printf "\n\n"
echo 'File: '$(basename "$0")
printf "\n"

source global.conf

printf "\n"
echo '===================== install postfix, postfix-mysql ====================='
debconf-set-selections <<<"postfix postfix/mailname string $myDomain"
debconf-set-selections <<<"postfix postfix/main_mailer_type string 'Internet Site'"
apt-get install -y postfix postfix-mysql
service postfix start

printf '\n'
echo '===================== config postfix ====================='
postconf -e "biff = no"
postconf -e 'broken_sasl_auth_clients = yes'
postconf -e "inet_interfaces = all"
postconf -e "inet_protocols = all"
postconf -e "mailbox_transport = lmtp:unix:private/dovecot-lmtp"
postconf -e "mydestination = localhost"
postconf -e "myhostname = ${myHost}.${myDomain}"
postconf -e "myorigin = /etc/mailname"
postconf -e "recipient_delimiter = +"
postconf -e 'smtp_tls_note_starttls_offer = yes'
postconf -e 'smtp_tls_security_level = may'
# postconf -e 'smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_scache'
postconf -e 'smtpd_banner = $myhostname ESMTP (Ubuntu)'
postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'
postconf -e "smtpd_sasl_auth_enable = yes"
postconf -e "smtpd_sasl_local_domain = $myDomain"
postconf -e "smtpd_sasl_path = private/auth"
postconf -e "smtpd_sasl_security_options = noanonymous"
postconf -e "smtpd_sasl_type = dovecot"
# liych note
postconf -e "smtpd_tls_auth_only = no"
postconf -e 'smtpd_tls_loglevel = 1'
postconf -e "smtpd_tls_cert_file = /etc/letsencrypt/live/${myDomain}/fullchain.pem"
postconf -e "smtpd_tls_key_file = /etc/letsencrypt/live/${myDomain}/privkey.pem"
# postconf -e 'smtpd_tls_received_header = yes'
postconf -e "smtpd_tls_security_level = may"
# postconf -e "smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache"

IFS=""
mkdir -p /etc/postfix/sql

cat >/etc/postfix/sql/mysql_virtual_alias_maps.cf <<EOF
user=${myDbUser}
password=${myDbPass}
hosts=127.0.0.1
dbname=${myDb}
query=SELECT goto FROM alias WHERE address='%s' AND active= '1'
EOF
postconf -e "virtual_alias_maps = mysql:/etc/postfix/sql/mysql_virtual_alias_maps.cf"

cat >/etc/postfix/sql/mysql_virtual_domains_maps.cf <<EOF
user=${myDbUser}
password=${myDbPass}
hosts=127.0.0.1
dbname=${myDb}
query=SELECT domain FROM domain WHERE domain='%s' AND active = '1'
EOF
postconf -e "virtual_mailbox_domains = mysql:/etc/postfix/sql/mysql_virtual_domains_maps.cf"

cat >/etc/postfix/sql/mysql_virtual_mailbox_maps.cf <<EOF
user=${myDbUser}
password=${myDbPass}
hosts=127.0.0.1
dbname=${myDb}
query=SELECT maildir FROM mailbox WHERE username='%s' AND active = '1'
EOF
postconf -e "virtual_mailbox_maps = mysql:/etc/postfix/sql/mysql_virtual_mailbox_maps.cf"

postconf -e "virtual_transport = lmtp:unix:private/dovecot-lmtp"
# postconf -e "mydomain = ${myDomain}"

#master.cf config
postconf -M submission/inet="submission       inet       n       -       y       -       -       smtpd"
postconf -P submission/inet/syslog_name=postfix/submission
postconf -P submission/inet/smtpd_tls_security_level=encrypt
postconf -P submission/inet/smtpd_sasl_auth_enable=yes
# postconf -P submission/inet/smtpd_sasl_auth_type=dovecot
# postconf -P submission/inet/smtpd_sasl_auth_path=private/auth
postconf -P submission/inet/smtpd_client_restrictions=permit_sasl_authenticated,reject

postconf -M smtps/inet="smtps       inet       n       -       y       -       -       smtpd"
postconf -P smtps/inet/syslog_name=postfix/smtps
postconf -P smtps/inet/smtpd_tls_wrappermode=yes
postconf -P smtps/inet/smtpd_sasl_auth_enable=yes
postconf -P smtps/inet/smtpd_client_restrictions=permit_sasl_authenticated,reject

postconf -M dovecot/unix="dovecot       unix       -       n       n       -       -       pipe"
# liych
#postconf -P { dovecot/unix/flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/deliver -f ${sender} -d ${user}@${nexthop} }
postconf -F "dovecot/unix/command=pipe flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/deliver -f \${sender} -d \${user}@\${nexthop}"

ufw allow "Postfix"
ufw allow "Postfix SMTPS"
ufw allow "Postfix Submission"

service postfix restart
