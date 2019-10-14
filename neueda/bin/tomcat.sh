#!/bin/bash
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

if ! (rpm -qa | grep rpmfusion >/dev/null 2>&1)
then
	yum -y install http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm
	
	systemctl disable firewalld
	systemctl stop firewalld
fi

if ! ( rpm -qa | grep tomcat >/dev/null 2>&1)
then
	yum -y install tomcat tomcat-webapps tomcat-admin-webapps
	echo "<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
<role rolename='manager-gui'/>
<user name='admin' password='admin' roles='manager-gui'/>
</tomcat-users>" >/etc/tomcat/tomcat-users.xml

	echo "/usr/sbin/setenforce 0" >>/etc/rc.local

	systemctl enable tomcat
	systemctl start tomcat
fi
