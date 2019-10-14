#!/bin/bash
# VM to run GitLab

if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

if ! grep student /etc/passwd >/dev/null 2>&1
then
	useradd -m student
	(sleep 5; echo "secret"; sleep 2; echo "secret") | passwd student
	systemctl stop firewalld
	systemctl disable firewalld
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
fi

yum -y update
if ! rpm -qa | grep rpmfusion >/dev/null 2>&1 
then
	yum -y install sharutils http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm
fi

if ! rpm -qa | grep ipa-server >/dev/null 2>&1
then
	yum -y install ipa-server bind bind-dyndb-ldap
fi

if ! rpm -qa | grep puppet >/dev/null 2>&1
then
	yum -y install puppet
fi

if [ ! -d /vagrant/puppet/modules/huit-ipa ]
then
	puppet module install --modulepath /vagrant/puppet/modules huit-ipa
fi

sed -i '/^127.0.0.1/{s/ldap.training.local//}' /etc/hosts
sed -i '/^127.0.0.1/{s/ldap//}' /etc/hosts

exit 0;
