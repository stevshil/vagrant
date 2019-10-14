#!/bin/bash
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

# VM to run Puppet Cert Auth

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
	yum -y install puppet puppet-server
	puppet resource package httpd ensure=present
	puppet resource package mod_ssl ensure=present
	puppet resource service httpd ensure=stopped
	puppet resource package rubygems ensure=present
	puppet resource package rack ensure=present provider=gem
	puppet resource package passenger ensure=present provider=gem
	yum -y install curl-devel ruby-devel httpd-devel apr-devel apr-util-devel openssl-devel zlib-devel

	sed -i '/\[main\]/a\
    server = puppetca.training.local' /etc/puppet/puppet.conf
	service puppetmaster start
	sleep 10
	if [ ! -f /var/lib/puppet/ssl/certs/puppetca.training.local.pem ]
	then
		if ! ps -ef | grep puppet-master | grep -v grep >/dev/null 2>&1
		then
			service puppetmaster start
		else
			service puppetmaster stop
		fi
	fi
	if service puppetmaster status >/dev/null 2>&1
	then
		service puppetmaster stop
		chkconfig puppetmaster off
	fi
	cp /vagrant/files/puppetca/passenger.conf /etc/httpd/conf.d/
	cp /vagrant/files/puppetca/puppetmaster_proxy.conf /etc/httpd/conf.d/
	# Set the version of passenger
	passenger=$(basename $(ls -d /usr/local/share/gems/gems/passenger*))
	sed -i "s/passenger-5.0.10/$passenger/" /etc/httpd/conf.d/passenger.conf
	mkdir -p /usr/share/puppet/rack/puppetmasterd/{public,tmp}
	cp /vagrant/files/puppetca/config.ru /usr/share/puppet/rack/puppetmasterd
	chown puppet /usr/share/puppet/rack/puppetmasterd/config.ru
	yes | /usr/local/bin/passenger-install-apache2-module
	puppet resource service httpd ensure=running enable=true hasstatus=true

	# Using an external CA
	# --dns-alt-names
	# https://docs.puppetlabs.com/guides/scaling_multiple_masters.html#centralize-the-certificate-authority

	echo "setenforce 0" >>/etc/rc.local

fi

exit 0;
