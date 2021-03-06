#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"

mysql -uroot -e "CREATE DATABASE magento DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci"
mysql -uroot -e "CREATE USER 'magento'@'%' IDENTIFIED BY '.uyen.12'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'magento'@'%' WITH GRANT OPTION"

mysqladmin -u root password "unknown"

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has password 'unknown' but only allows local connections"
echo "========================================================================"

mysqladmin -uroot -punknown shutdown
