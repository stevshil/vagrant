#!/bin/bash
# VM to run GitLab

if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

if ! grep 'SELINUX=disabled' /etc/sysconfig/selinux >/dev/null 2>&1
then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
fi

yum -y update
if ! rpm -qa | grep rpmfusion >/dev/null 2>&1 
then
	yum -y install sharutils http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm
fi

if ! rpm -qa | grep puppet >/dev/null 2>&1
then
	yum -y install puppet
fi

exit 0;
