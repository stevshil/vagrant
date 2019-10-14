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
	setenforce 0
fi

# Update system
yum -y update

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

if ! rpm -qa | grep docker >/dev/null 2>&1
then
	yum -y install docker
fi

if rpm -qa | grep docker >/dev/null 2>&1
then
	if ! service docker status >/dev/null 2>&1
	then
		service docker start
	fi
fi

if sudo systemctl list-unit-files | grep docker.service | grep disable >/dev/null 2>&1
then
	systemctl enable docker.service
fi

if grep docker /etc/group | grep -v vagrant >/dev/null 2>&1
then
	groupadd docker
	useradd -G docker vagrant
fi

if ! rpm -qa | grep python-pip >/dev/null 2>&1
then
	yum -y install python-pip
fi

if ! rpm -qa | grep -i chef >/dev/null 2>&1
then
	yum -y install https://packages.chef.io/stable/el/7/chefdk-0.17.17-1.el7.x86_64.rpm
fi
