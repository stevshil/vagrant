#!/bin/bash
# https://www.digitalocean.com/community/tutorials/how-to-install-puppet-4-in-a-master-agent-setup-on-centos-7
# https://puppet.com/download-open-source-puppet/thank-you
# How to install puppet
#      https://docs.puppet.com/puppet/latest/reference/puppet_collections.html
# VM to run Puppet Opensource master
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

setenforce 0

if grep '^SELINUX=enforcing' /etc/sysconfig/selinux >/dev/null 2>&1
then
	systemctl stop firewalld
	systemctl disable firewalld
	sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
fi

if [[ ! -e /etc/yum.repos.d/puppetlabs-pc1.repo ]]
then
	yum -y install https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
fi

hostname
if [[ $(hostname) == "puppetmaster.training.local" ]]
then
	# Install server
	echo "INSTALLING MASTER"
	if ! rpm -qa | grep 'puppet[^l][^a]' | grep -v grep >/dev/null 2>&1
	then
		yum -y install puppetserver
    systemctl enable puppetserver.service
	fi
else
	# Install client
	echo "INSTALLING CLIENT"
	if ! rpm -qa | grep 'puppet[^l][^a]' | grep -v grep >/dev//null 2>&1
	then
		yum -y install puppet-agent
	fi
  # Install git on studentpuppet
  if (! which git >/dev/null 2>&1) && [[ $(hostname) == "student.training.local" ]]
  then
    yum -y install git
    # Install development tools to be able to install hiera-gpg
    yum -y groupinstall "Development Tools"
  fi
fi

if ! grep "192.168.18.100" /etc/hosts
then
	echo "192.168.18.100	puppetmaster.training.local" >>/etc/hosts
fi
if ! grep "192.168.18.101" /etc/hosts
then
	echo "192.168.18.101	puppetclient.training.local" >>/etc/hosts
fi

# Add the relvanant CentOS 7 network requirements to bring network up on boot
if ! grep 'TYPE=Ethernet' /etc/sysconfig/network-scripts/ifcfg-enp0s8 >/dev/null 2>&1
then
  echo "TYPE=Ethernet" >>/etc/sysconfig/network-scripts/ifcfg-enp0s8
  echo "NAME=enp0s8" >>/etc/sysconfig/network-scripts/ifcfg-enp0s8
fi

# Set 2nd interface to be NM controlled
if grep 'NM_CONTROLLED=no' /etc/sysconfig/network-scripts/ifcfg-enp0s8 >/dev/null 2>&1
then
  sed -i 's/^NM_CONTROLLED=no/NM_CONTROLLED=yes/' /etc/sysconfig/network-scripts/ifcfg-enp0s8
fi

# Start network interface 2
if ! ifconfig | grep enp0s8 >/dev/null 2>&1
then
  service network restart
fi

exit 0;
