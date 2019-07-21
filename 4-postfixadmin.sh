#!/bin/bash

source config.conf

wget https://sourceforge.net/projects/postfixadmin/files/latest/download
tar xvf postfixadmin-*.tar.gz postfixadmin

sudo install postfixadmin/ /var/www/postfixadmin

sudo cat >/ar/www/postfixadmin/config.local.php <<EOF
<?php
$CONF['database_type'] = 'mysqli';
$CONF['database_user'] = ${mysqlUser};
$CONF['database_password'] = ${mysqlPass};
$CONF['database_name'] = ${mysqlDb};

$CONF['configured'] = true;
?>
EOF

sudo mkdir /var/www/postfixadmin/templates_c && chmod 755 -R /var/www/postfixadmin/templates_c
sudo chown -R www-data: /var/www/postfixadmin
