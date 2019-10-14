#!/bin/bash

yum -y install wget httpd
yum -y install php postgresql-server postgresql unzip git
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install nodejs npm
postgresql-setup initdb
systemctl start postgresql.service
systemctl enable postgresql.service

if [[ ! -d Gradebook ]]
then
	git clone https://github.com/DASSL/Gradebook.git
fi

wd=$PWD

# Edit the postgresql.conf file in /var/lib/pgsql/data/
# /var/lib/pgsql/data/pg_hba.conf

cd Gradebook/src/db
sudo -u postgres psql -c "CREATE ROLE gradebook WITH LOGIN ENCRYPTED PASSWORD 'secret';"
sudo -u postgres psql -c "CREATE ROLE gb_webApp WITH LOGIN ENCRYPTED PASSWORD 'secret';"
##sudo -u postgres psql -c 'CREATE DATABASE GB_DATA WITH OWNER gradebook;'
#sudo -u postgres psql -c 'CREATE DATABASE Gradebook WITH OWNER gradebook;'
#export PGPASSWORD=secret

cd "$wd"
cd Gradebook/src/webapp
npm install

#if [[ ! -e v16.0.01.zip ]]
#then
	#wget https://github.com/GibbonEdu/core/archive/v16.0.01.zip
#fi
