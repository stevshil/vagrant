#!/bin/bash
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

setenforce 0

if ps -ef | grep firewalld | grep -v grep >/dev/null 2>&1
then
	systemctl disable firewalld
	systemctl stop firewalld
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
fi

yum -y update
yum -y install mariadb mariadb-libs mariadb-server java mysql-connector-java ant

if ! grep student /etc/passwd >/dev/null 2>&1
then
	useradd -m student
	(sleep 5; echo "secret"; sleep 2; echo "secret") | passwd student
fi

service mariadb start
chkconfig mariadb on

cd /home/student
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.45-30.b13.el7_1.x86_64/jre" >>/home/student/.bash_profile

mysql -u root </vagrant/files/axis2.sql

# Get the LinuxProd system
if [ ! -e /vagrant/files/AutoTrader-Generic-WithCode-LinuxReady.tgz ]
then
	curl https://dl.dropboxusercontent.com/u/5682093/Neueda/AutoTrader-Generic-WithCode-LinuxReady.tgz >/vagrant/files/AutoTrader-Generic-WithCode-LinuxReady.tgz
fi

# Copy the app
tar xvf /vagrant/files/AutoTrader-Generic-WithCode-LinuxReady.tgz
mv axis2-1.6.3-EnvVars-Source-Generic-PS autotrader
cd autotrader
cp /vagrant/files/axis2server.sh /home/student/autotrader/bin
chown -R student:student /home/student

# Build the software using ant
cd /home/student/autotrader/projects/equitytrader
ant
# Remove the source (How mean do you want to be?)
# rm -rf /home/student/autotrader/projects/equitytrader

# Set up root to use the database
mysql -u root <<_END_
CREATE USER 'student'@'localhost' IDENTIFIED BY 'student';
GRANT ALL ON *.* TO 'student'@'localhost' IDENTIFIED BY 'student';
_END_


# The following would start the service
#. /home/student/.bash_profile
#cd /home/student/quickfixj
#bin/executor.sh bin/executor.cfg &
#cd /home/student
#bin/axis2server.sh &
