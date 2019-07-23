#!/bin/bash

printf "\n\n"
echo $(basename "$0")

apt-get -y install dovecot-imapd dovecot-mysql dovecot-lmtpd dovecot-managesieved dovecot-core
service dovecot start

#uncomment !include conf.d/*.conf
sed -i '/\!include conf\.d\/\*\.conf/s/^#//' /etc/dovecot/dovecot.conf
status= $(grep "protocols = imap lmtp" /etc/dovecot/dovecot.conf)
if [ -z $status ]; then
  echo "protocols = imap lmtp" >>/etc/dovecot/dovecot.conf
fi

sed -i '/^mail_location =.*/s/^/#/g' /etc/dovecot/conf.d/10-mail.conf #comment default mail_location
echo "mail_location = maildir:/var/mail/vmail/%d/%n" >>/etc/dovecot/conf.d/10-mail.conf

sudo sed -i '/^mail_privileged_group =.*/s/^/#/g' /etc/dovecot/conf.d/10-mail.conf
sudo echo "mail_privileged_group = vmail" >>/etc/dovecot/conf.d/10-mail.conf

sudo sed -i '/^auth_mechanisms =.*/s/^/#/g' /etc/dovecot/conf.d/10-auth.conf
sudo echo "auth_mechanisms = plain" >>/etc/dovecot/conf.d/10-auth.conf

sudo sed -i '/\!include auth-system\.conf\.ext/s/^/#/g' /etc/dovecot/conf.d/10-auth.conf

sudo sed -i '/\!include auth-sql\.conf\.ext/s/^#//g' /etc/dovecot/conf.d/10-auth.conf

if [[ ! -f /etc/dovecot/conf.d/auth-sql.conf.ext.orig ]]; then
  mv /etc/dovecot/conf.d/auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext.orig
fi

sudo echo >/etc/dovecot/conf.d/auth-sql.conf.ext <<EOF
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
userdb {
  driver = static
  args = uid=vmail gid=vmail home=/var/mail/vmail/%d/%n
}
EOF

sudo sed -i '/^driver =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
sudo echo "driver = mysql" >>/etc/dovecot/dovecot-sql.conf.ext

sudo sed -i '/^connect =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
sudo echo "connect = host=127.0.0.1 dbname=$mysqlDb user=$mysqlUser password=$mysqlPass" >>/etc/dovecot/dovecot-sql.conf.ext

sudo sed -i '/^default_pass_scheme =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
sudo echo "default_pass_scheme = SHA512-CRYPT" >>/etc/dovecot/dovecot-sql.conf.ext

sudo sed -i '/^password_query =.*/s/^/#/g' /etc/dovecot/dovecot-sql.conf.ext
sudo echo "password_query = SELECT email as user, password FROM virtual_users WHERE email='%u';" >>/etc/dovecot/dovecot-sql.conf.ext

sudo chown -R vmail:dovecot /etc/dovecot
sudo chmod -R o-rwx /etc/dovecot

sudo echo >/etc/dovecot/conf.d/10-master.conf <<EOF
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
   mode = 0600
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
   #group =
  }
  # Auth process is run as this user.
  user = dovecot
}
service auth-worker {
  user = vmail
}
service dict {
  unix_listener dict {
  }
}
EOF

service dovecot restart
service postfix restart

echo "\n\nYour mail server should be accessible now."
unset $IFS
