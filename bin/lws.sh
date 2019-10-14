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
	sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/sysconfig/selinux
	setenforce 0
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

if ! (rpm -qa | grep mariadb-server >/dev/null 2>&1 )
then
	echo "Installing MySQL"
	yum -y install mariadb-server mariadb
	sed -i 's,datadir=/var/lib/mysql,datadir=/home/mysql,' /etc/my.cnf
	sed -i '/socket=/i\innodb_log_file_size = 50331648' /etc/my.cnf
	cp -r /copy/mysql /home/mysql
	chown -R mysql:mysql /home/mysql
	systemctl enable mariadb
	systemctl restart mariadb
fi

if ! ( rpm -qa | grep mod_perl >/dev/null 2>&1 )
then
	echo "Installing mod_perl"
	yum -y install mod_perl perl-CGI
fi

if ! ( ls /etc/httpd/conf.d/mysites.conf >/dev/null 2>&1 )
then
	echo "Installing web site configuration"
	workingdir="$PWD"
	cd /etc/httpd/conf.d
	ln -s /vagrant/files/lws/mysites.conf mysites.conf
	cd ../conf
	sed -i 's/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi .pl/' httpd.conf
	service httpd restart
	cd $workingdir
fi

if ! ( ls /home/mysql >/dev/null 2>&1 )
then
	cp -r /copy/mysql /home/mysql
	chown -R mysql:mysql /home/mysql
	systemctl enable mariadb
	systemctl restart mariadb
fi
