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

if ! ( rpm -qa | grep mariadb-server >/dev/null 2>&1)
then
	echo "Installing MySQL"
	yum -y install mariadb-server mariadb
fi

if ! rpm -qa | egrep 'php-mysql|php-imap|php-xml'
then
	echo "Installing php dependencies"
	yum -y install php-mysql php-imap php-xml >/dev/null 2>&1
	systemctl restart httpd
fi

if ! systemctl status mariadb >/dev/null 2>&1
then
	systemctl enable mariadb
	systemctl start mariadb
fi

if ! ls /var/www/html/upload >/dev/null 2>&1
then
	echo "Installing Kanboard"
	wget -O /tmp/osticket.zip http://osticket.com/sites/default/files/download/osTicket-v1.9.12.zip
	cd /var/www/html
	unzip /tmp/osticket.zip
	chown -R apache:apache upload scripts
	if ! ls upload/include/ost-config.php >/dev/nul 2>&1
	then
		cp upload/include/ost-sampleconfig.php upload/include/ost-config.php
		chmod 666 upload/include/ost-config.php
	fi
fi

# Default login is admin/admin
setenforce 0
