#!/bin/bash

printf "\n\n"
echo 'File: '$(basename "$0")

source global.conf

echo
echo '====================== install mysql-server, php-mysql ======================'
apt-get -y install mysql-server php-mysql

echo
echo '====================== config mysql database ======================'
sqlCmd=(
    "use mysql;"
    "update user set authentication_string=PASSWORD(\'$myDbPass\') where user='root';"
    "DROP DATABASE IF EXISTS ${myDb};"
    "CREATE DATABASE ${myDb};"
    "GRANT ALL PRIVILEGES ON ${myDb}.* TO '${myDbUser}'@'localhost' IDENTIFIED BY '${myDbPass}';"
    "FLUSH PRIVILEGES;"
)

for ((i = 0; i < ${#SQLCMDARRAY[@]}; i++)); do
    echo ${SQLCMDARRAY[$i]}
    mysql -u root -p $myDbPass -e "${SQLCMDARRAY[$i]}"
    if [[ $? -eq 1 ]]; then
        echo "SQL failed: '${SQLCMDARRAY[$i]}'"
        exit 1
    fi
done
