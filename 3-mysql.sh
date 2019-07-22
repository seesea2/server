#!/bin/bash

source config.conf

apt-get -y install mysql-server php-mysql >/dev/null

sqlCmd=(
    "DROP DATABASE IF EXISTS ${mysqlDb}"
    "CREATE DATABASE ${mysqlDb}"
    "GRANT ALL PRIVILEGES ON ${mysqlDb}.* TO '${mysqlUser}'@'localhost' IDENTIFIED BY '${mysqlPass}'"
    "FLUSH PRIVILEGES"
)

for ((i = 0; i < ${#SQLCMDARRAY[@]}; i++)); do
    mysql -u root -p ${mysqlPass} -e "${SQLCMDARRAY[$i]}"
    if [[ $? -eq 1 ]]; then
        echo "SQL failed: '${SQLCMDARRAY[$i]}'"
        exit 1
    fi
done
