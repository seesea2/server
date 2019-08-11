#!/bin/bash

printf "\n\n"
echo 'File: '$(basename "$0")

source global.conf

echo ""
echo "===================== install dovecot ====================="
apt-get -y install dovecot-imapd dovecot-mysql dovecot-lmtpd dovecot-managesieved dovecot-core
service dovecot start

echo ""
echo "===================== config dovecot ====================="
# uncomment !include conf.d/*.conf
sed -i '/\!include conf\.d\/\*\.conf/s/^#//' /etc/dovecot/dovecot.conf

sed -i '/^mail_location =.*/s/^/#/g' /etc/dovecot/conf.d/10-mail.conf #comment default mail_location
echo "mail_location = maildir:/var/mail/vmail/%d/%n/Maildir" >>/etc/dovecot/conf.d/10-mail.conf

sed -i '/^mail_privileged_group =.*/s/^/#/g' /etc/dovecot/conf.d/10-mail.conf
echo "mail_privileged_group = vmail" >>/etc/dovecot/conf.d/10-mail.conf

echo "protocols = imap lmtp sieve" >/etc/dovecot/local.conf

cat >/etc/dovecot/conf.d/10-master.conf <<EOF
service imap-login {
  inet_listener imap {
    port = 0
  }
  inet_listener imaps {
    port = 993
    ssl = yes
  }
}
service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
   mode = 0660
   user = postfix
   group = postfix
  }
}
service imap {
}
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }
  unix_listener auth-userdb {
   mode = 0600
   user = vmail
  }
  # Auth process is run as this user.
  user = dovecot
}
service auth-worker {
  # user = vmail
}
service dict {
  unix_listener dict {
  }
}
EOF

# conf.d/10-ssl.conf
sed -i '/^ssl =.*/s/^/#/g' /etc/dovecot/conf.d/10-ssl.conf
echo 'ssl = yes' >>/etc/dovecot/conf.d/10-ssl.conf
sed -i '/^ssl_cert =.*/s/^/#/g' /etc/dovecot/conf.d/10-ssl.conf
echo "ssl_cert = </etc/letsencrypt/live/${myDomain}/fullchain.pem" >>/etc/dovecot/conf.d/10-ssl.conf
sed -i '/^ssl_key =.*/s/^/#/g' /etc/dovecot/conf.d/10-ssl.conf
echo "ssl_key = </etc/letsencrypt/live/${myDomain}/privkey.pem" >>/etc/dovecot/conf.d/10-ssl.conf

cat >/etc/dovecot/conf.d/auth-sql.conf.ext <<EOF
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
userdb {
   driver = static
   args = uid=vmail gid=vmail home=/var/mail/vmail/%d/%n
}
EOF

# conf.d/20-lmtp.conf:    postmaster_address = postmaster@insg.xyz
sed -i "s/postmaster_address =.*/postmaster_address = postmaster@${myDomain}/g" /etc/dovecot/conf.d/20-lmtp.conf
sed -i "s/mail_plugins =.*/mail_plugins = \$mail_plugins sieve/g" /etc/dovecot/conf.d/20-lmtp.conf

sed -i '/^auth_mechanisms =.*/s/^/#/g' /etc/dovecot/conf.d/10-auth.conf
echo "auth_mechanisms = plain login" >>/etc/dovecot/conf.d/10-auth.conf

sed -i '/\!include auth-system\.conf\.ext/s/^/#/g' /etc/dovecot/conf.d/10-auth.conf
sed -i '/\!include auth-sql\.conf\.ext/s/^#//g' /etc/dovecot/conf.d/10-auth.conf

sed -i '/^driver =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
echo "driver = mysql" >>/etc/dovecot/dovecot-sql.conf.ext
sed -i '/^connect =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
echo "connect = host=127.0.0.1 dbname=$myDb user=$myDbUser password=$myDbPass" >>/etc/dovecot/dovecot-sql.conf.ext

sed -i '/^default_pass_scheme =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
echo "default_pass_scheme = SHA512-CRYPT" >>/etc/dovecot/dovecot-sql.conf.ext

sed -i '/^password_query =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
echo "password_query = SELECT username, domain, password FROM mailbox WHERE username='%u';" >>/etc/dovecot/dovecot-sql.conf.ext

chown -R vmail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot

ufw allow "Dovecot Secure IMAP"

service dovecot restart
service postfix restart

echo ""
echo "Your mail server should be working now."
unset $IFS
