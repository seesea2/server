#!/bin/bash

printf "\n\n"
echo $(basename "$0")
 
source config.conf

wget -q https://sourceforge.net/projects/postfixadmin/files/latest/download -O postfixadmin.tar.gz
tar xvf postfixadmin.tar.gz >/dev/null
rm postfixadmin.tar.gz

mv postfixadmin-*/ /var/www/postfixadmin

cat >/var/www/postfixadmin/config.local.php <<EOF
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
