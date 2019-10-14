#!/bin/bash
# Provisioning script to install ansible on Debian or RHEL based linux

if uname -a | grep -i ubuntu >/dev/null 2>&1
then
	apt-get -y install python pip
	#pip install paramiko PyYAML Jinja2 httplib2 six ansible
	apt-get -y install software-properties-common
	apt-add-repository -y ppa:ansible/ansible
	apt-get -y update
	apt-get -y install ansible
else
	install='yum -y install'
	dependency="python python-pip"
	# Add RPM fusion
	if ! rpm -qa | grep rpmfusion >/dev/null 2>&1
	then
		yum -y install http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm
	fi
	# Add Compiler
	if ! yum -y grouplist installed | grep "Development Tools" >/dev/null 2>&1
	then
		yum -y groupinstall "Development Tools"
	fi

	if ! rpm -qa | grep ansible >/dev/null 2>&1
	then
		yum -y install ansible
	fi
fi
