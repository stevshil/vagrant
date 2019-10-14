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

# Set the hosts for Puppet
echo "192.168.18.100    puppetmaster.training.local puppetmaster
192.168.18.12   puppetmaster-1.training.local puppetworker
192.168.18.11   puppetmaster-2.training.local puppetsrv
192.168.18.10   puppetca-1.training.local puppetca-1
192.168.18.5	puppetnfs.training.local puppetnfs" >>/etc/hosts

# Configure NFS
if ! ((rpm -qa | grep nfs-utils) && (rpm -qa | grep rpcbind)) >/dev/null 2>&1
then
	# Install NFS
	yum -y install nfs-utils nfs4-acl-tools rpcbind
	systemctl enable nfs
	systemctl enable rpcbind
	systemctl start rpcbind
fi

# Check we have a puppet user for puppet
if ! grep puppet /etc/passwd >/dev/null 2>&1
then
	groupadd -g52 puppet
	useradd -u52 -g52 -c'Puppet' -d'/var/lib/puppet' -s'/sbin/nologin' puppet
fi

# Create the puppet server shared directory
if [ ! -d /puppet ]
then
	mkdir -p /puppet/ssl/ca/signed /puppet/ssl/ca/requests /puppet/reports /puppet/yaml/node /puppet/yaml/facts /puppet/ssl/private_keys /puppet/ssl/public_keys
	chown -R puppet:puppet /puppet
	echo "/puppet	192.168.18.0/24(rw,no_root_squash)" >>/etc/exports
	systemctl restart nfs
fi

echo "/usr/sbin/setenforce 0" >>/etc/rc.local

exit 0;
