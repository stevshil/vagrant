#!/bin/bash
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

if ! (rpm -qa | grep rpmfusion >/dev/null 2>&1)
then
	echo "Installing extra repositories"
	yum -y install http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm >/dev/null 2>&1
	
	echo "Disabling firewall"
	systemctl disable firewalld
	systemctl stop firewalld
	echo "/usr/sbin/setenforce 0" >>/etc/rc.local
fi

if ! rpm -qa | grep 'wget' >/dev/null 2>&1
then
	echo "Installing wget"
	yum -y install  wget >/dev/null 2>&1
fi

if ! rpm -qa | grep 'unzip' >/dev/null 2>&1
then
	echo "Installing unzip"
	yum -y install unzip >/dev/null 2>&1
fi

if ! rpm -qa | grep php >/dev/null 2>&1
then
	echo "Installing PHP"
	yum -y install php php-mbstring php-gd php-pdo
fi

if ! ( rpm -qa | grep httpd >/dev/null 2>&1)
then
	echo "Installing Apache"
	yum -y install httpd
fi
if ! systemctl status httpd >/dev/null 2>&1
then
	systemctl enable httpd
	systemctl start httpd
fi

if ! ls /var/www/html/kanboard >/dev/null 2>&1
then
	echo "Installing Kanboard"
	wget -O /tmp/kanboard-latest.zip http://kanboard.net/kanboard-latest.zip
	cd /var/www/html
	unzip /tmp/kanboard-latest.zip
	chown -R apache:apache kanboard
	chmod 1777 kanboard/data
	cd kanboard
	php index.php
fi

# Default login is admin/admin
setenforce 0
