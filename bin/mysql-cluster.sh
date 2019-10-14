#!/bin/bash

# Ensure private NIC is up
ifup enp0s8

if [[ ! -e /vagrant/MySQL-Cluster-gpl-7.4.10-1.el7.x86_64.rpm-bundle.tar ]]
then
	wget http://dev.mysql.com/get/Downloads/MySQL-Cluster-7.4/MySQL-Cluster-gpl-7.4.10-1.el7.x86_64.rpm-bundle.tar -P /vagrant
fi

if rpm -qa | grep mariadb-libs >/dev/null 2>&1
then
	yum -y remove mariadb-libs
fi

if ! rpm -qa | grep perl-Data-Dumper >/dev/null 2>&1
then
	yum -y install perl-Data-Dumper
fi

if ! rpm -qa | grep MySQL-Cluster >/dev/null 2>&1
then
	tar xvf /vagrant/MySQL-Cluster-gpl-7.4.10-1.el7.x86_64.rpm-bundle.tar
	yum -y localinstall MySQL-Cluster-client-gpl-7.4.10-1.el7.x86_64.rpm MySQL-Cluster-server-gpl-7.4.10-1.el7.x86_64.rpm MySQL-Cluster-shared-gpl-7.4.10-1.el7.x86_64.rpm
fi

if [[ ! -d /var/lib/mysql-cluster ]]
then
	mkdir -p /var/lib/mysql-cluster
fi

# Start the manager
if ifconfig | grep ' 10.0.0.2 ' >/dev/null 2>&1
then

echo "
[ndb_mgmd default]
# Directory for MGM node log files
DataDir=/var/lib/mysql-cluster
 
[ndb_mgmd]
#Management Node db1
NodeId=1
HostName=10.0.0.2
 
[ndbd default]
NoOfReplicas=2      # Number of replicas
DataMemory=256M     # Memory allocate for data storage
IndexMemory=128M    # Memory allocate for index storage
#Directory for Data Node
DataDir=/var/lib/mysql-cluster
 
[ndbd]
#Data Node db2
NodeId=2
HostName=10.0.0.3
 
[ndbd]
#Data Node db3
NodeId=3
HostName=10.0.0.4
 
[mysqld]
#SQL Node db4
NodeId=4
HostName=10.0.0.3
 
[mysqld]
#SQL Node db5
NodeId=5
HostName=10.0.0.4
" >/var/lib/mysql-cluster/config.ini

	if ! ps -ef | gerp ndb_mgmd >/dev/null 2>&1
	then
		ndb_mgmd --config-file=/var/lib/mysql-cluster/config.ini --ndb-nodeid=1
	fi
fi

# Data and SQL nodes
if ! ifconfig | grep ' 10.0.0.2 ' >/dev/null 2>&1
then

	if ifconfig | grep ' 10.0.0.3 ' >/dev/null 2>&1
	then
		nodeid=4
	else
		nodeid=5
	fi

echo "
[mysqld]
user=mysql
ndbcluster
ndb-connectstring=10.0.0.2
default_storage_engine=ndbcluster

[mysql_cluster]
ndb-connectstring=10.0.0.2
" >/etc/my.cnf

	if (( $(ps -ef | grep ndbd | grep -v grep | wc -l) == 0 ))
	then
		ndbd
		sudo mysql_install_db --user=mysql --ldata=/var/lib/mysql
		service mysql start
	fi

	# Set the root password
	mysql --connect-expired-password -u root -p$(sudo cat /root/.mysql_secret | awk '{print $NF}') <<_END_
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('secret');
\q
_END_

fi
