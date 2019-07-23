#!/bin/bash

printf "\n\n"
echo $(basename "$0")

source global.conf

echo install mysql-server, php-mysql
apt-get -y install mysql-server php-mysql >/dev/null

sqlCmd=(
    "DROP DATABASE IF EXISTS ${myDb};"
    "CREATE DATABASE ${myDb};"
    "GRANT ALL PRIVILEGES ON ${myDb}.* TO '${myDbUser}'@'localhost' IDENTIFIED BY '${myDbPass}';"
    "FLUSH PRIVILEGES;"
)

for ((i = 0; i < ${#SQLCMDARRAY[@]}; i++)); do
    mysql -u root -p password -e "${SQLCMDARRAY[$i]}"
    if [[ $? -eq 1 ]]; then
        echo "SQL failed: '${SQLCMDARRAY[$i]}'"
        exit 1
    fi
done
