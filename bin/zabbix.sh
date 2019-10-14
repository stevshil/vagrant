#!/bin/bash

apt-get -y update
apt-get -y install zabbix-server-pgsql postgresql-9.3

mkdir /var/run/zabbix /var/log/zabbix-server
chmod 777 /var/run/zabbix

echo "LogFile=/var/log/zabbix-server/zabbix_server.log
PidFile=/var/run/zabbix/zabbix_server.pid
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix
AlertScriptsPath=/etc/zabbix/alert.d/
FpingLocation=/usr/bin/fping" >/etc/zabbix/zabbix_server.conf

chmod 644 /etc/zabbix/zabbix_server.conf

echo "local   all             postgres                                peer
local   all             zabbix                                peer
#local   all             all                                     peer
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 md5" >/etc/postgresql/9.3/main/pg_hba.conf

service postgresql restart

sudo -u postgres psql -c 'create database zabbix;'
sudo -u postgres psql -c 'create user zabbix with superuser;'
sudo -u postgres psql -c "alter user zabbix with PASSWORD 'zabbix';"

zcat /usr/share/zabbix-server-pgsql/{schema,images,data}.sql.gz | psql -h localhost zabbix zabbix

# Now install web ui
apt-get -y install zabbix-frontend-php

cp /usr/share/doc/zabbix-frontend-php/examples/zabbix.conf.php.example /usr/share/zabbix/conf/zabbix.conf.php

cp /usr/share/doc/zabbix-frontend-php/examples/apache.conf /etc/apache2/conf-enabled/zabbix.conf

a2enmod alias

cp -f /vagrant/files/zabbix-php.ini /etc/php5/apache2/php.ini
cp -f /vagrant/files/zabbix.conf.php /etc/zabbix

service apache2 restart

echo 'START=yes
CONFIG_FILE="/etc/zabbix/zabbix_server.conf"' >/etc/default/zabbix-server

#service zabbix-server start
zabbix_server -c /etc/zabbix/zabbix_server.conf

# Default login is Admin/zabbix
