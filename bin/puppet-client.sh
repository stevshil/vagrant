#!/bin/bash
# VM to run Puppet Cert Auth
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

setenforce 0

if ! grep student /etc/passwd >/dev/null 2>&1
then
	useradd -m student
	(sleep 5; echo "secret"; sleep 2; echo "secret") | passwd student
	systemctl stop firewalld
	systemctl disable firewalld
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
fi

#yum -y update
if ! rpm -qa | grep rpmfusion >/dev/null 2>&1 
then
	yum -y install sharutils http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm
fi

if ! rpm -qa | grep puppet >/dev/null 2>&1
then
	yum -y install puppet

	sed -i '/\[main\]/a\
    server = puppetsrv.training.local' /etc/puppet/puppet.conf
echo "192.168.18.100    puppetmaster.training.local puppetmaster
192.168.18.12   puppetmaster-1.training.local puppetworker
192.168.18.11   puppetmaster-2.training.local puppetsrv
192.168.18.10   puppetca-1.training.local puppetca-1
192.168.18.20	puppetcli.training.local puppetcli" >>/etc/hosts

	# Using an external CA
	# --dns-alt-names
	# https://docs.puppetlabs.com/guides/scaling_multiple_masters.html#centralize-the-certificate-authority

fi

exit 0;
