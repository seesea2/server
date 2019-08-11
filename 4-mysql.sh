#!/bin/bash

printf "\n\n"
echo 'File: '$(basename "$0")

source global.conf

echo
echo '====================== install mysql-server ======================'
apt-get -y install mysql-server

echo
echo '====================== config mysql database ======================'
sqlCmd=(
    "update mysql.user set authentication_string=PASSWORD('$myDbPass') where user='root';"
    "DROP DATABASE IF EXISTS ${myDb};"
    "CREATE DATABASE ${myDb};"
    "GRANT ALL PRIVILEGES ON ${myDb}.* TO '${myDbUser}'@'localhost' IDENTIFIED BY '${myDbPass}';"
    "FLUSH PRIVILEGES;"
)

for ((i = 0; i < ${#sqlCmd[@]}; i++)); do
    mysql -u root -e "${sqlCmd[$i]}"
    if [[ $? -eq 1 ]]; then
        echo "SQL failed: '${sqlCmd[$i]}'"
        exit 1
    fi
done
