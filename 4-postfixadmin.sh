#!/bin/bash

source config.conf

wget https://sourceforge.net/projects/postfixadmin/files/latest/download
tar xvf postfixadmin-*.tar.gz postfixadmin

install postfixadmin/ /var/www/postfixadmin

cat >/ar/www/postfixadmin/config.local.php <<EOF
  <?php
  $CONF['database_type'] = 'mysqli';
  $CONF['database_user'] = ${myDbUser};
  $CONF['database_password'] = ${myDbPass};
  $CONF['database_name'] = ${myDb};

  $CONF['configured'] = true;
  ?>
EOF

mkdir /var/www/postfixadmin/templates_c && chmod 755 -R /var/www/postfixadmin/templates_c
chown -R www-data: /var/www/postfixadmin
