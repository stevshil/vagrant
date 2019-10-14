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

echo "192.168.18.100    puppetmaster.training.local puppetmaster
192.168.18.12   puppetmaster-1.training.local puppetworker
192.168.18.11   puppetmaster-2.training.local puppetsrv
192.168.18.10   puppetca-1.training.local puppetca-1
192.168.18.5	puppetnfs.training.local puppetnfs" >>/etc/hosts

if ! rpm -qa | grep puppet >/dev/null 2>&1
then
	# Need to create NFS server to share the certificates and node info
	yum -y install nfs-utils
	mkdir /var/lib/puppet
        systemctl enable rpcbind
        systemctl start rpcbind
	echo "puppetnfs:/puppet	/var/lib/puppet	nfs	defaults	0 0" >>/etc/fstab
	mount -t nfs puppetnfs:/puppet /var/lib/puppet
	yum -y install puppet puppet-server
	puppet resource package httpd ensure=present
	puppet resource package mod_ssl ensure=present
	puppet resource service httpd ensure=stopped
	puppet resource package rubygems ensure=present
	puppet resource package rack ensure=present provider=gem
	puppet resource package passenger ensure=present provider=gem
	yum -y install curl-devel ruby-devel httpd-devel apr-devel apr-util-devel openssl-devel zlib-devel

	sed -i '/\[main\]/a\
    server = puppetmaster.training.local' /etc/puppet/puppet.conf

	#mkdir /var/lib/puppet/shared
	#echo "puppetnfs:/puppet	/var/lib/puppet/shared nfs defaults 0 0" >>/etc/fstab
	#if mount -t nfs puppetnfs:/puppet /var/lib/puppet/shared >/dev/null 2>&1
	#then
		#cd /var/lib/puppet/ssl/ca
		#rm -rf signed
		#ln -s ../../shared/ssl/ca/signed signed
		#rm -rf requests
		#ln -s ../../shared/ssl/ca/requests requests
		#cd ..
		#rm -rf private_keys public_keys
		#ln -s ../shared/private_keys private_keys
		#ln -s ../shared/public_keys public_keys
		#cd ..
		#rm -rf reports
		#ln -s shared/reports reports
		#cd yaml
		#rm -rf node facts
		#ln -s ../shared/yaml/node node
		#ln -s ../shared/yaml/facts facts
	#fi

	# Set the certificate before starting the server
	if [ ! -f /var/lib/puppet/ssl/private_keys/puppetsrv.training.local.pem ]
	then
		if hostname | grep puppetsrv.training.local >/dev/null 2>&1
		then
			puppet cert generate puppetsrv.training.local --dns_alt_names=puppetmaster.training.local,puppetworker.training.local
		fi
		if hostname | grep puppetworker.training.local >/dev/null 2>&1
		then
			puppet cert generate puppetworker.training.local --dns_alt_names=puppetmaster.training.local,puppetsrv.training.local
		fi
	fi

	service puppetmaster start
	sleep 10
	if [ ! -f /var/lib/puppet/ssl/certs/puppetsrv.training.local.pem ]
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

	cp /vagrant/files/puppet-passenger/passenger.conf /etc/httpd/conf.d/
	# Set the version of passenger
	passenger=$(basename $(ls -d /usr/local/share/gems/gems/passenger*))
	sed -i "s/passenger-5.0.10/$passenger/" /etc/httpd/conf.d/passenger.conf
	sed -i "s/puppetsrv.training.local/$(hostname)/" /etc/httpd/conf.d/passenger.conf
	yes | /usr/local/bin/passenger-install-apache2-module
	puppet resource service httpd ensure=running enable=true hasstatus=true

	mkdir -p /usr/share/puppet/rack/puppetmasterd/{public,tmp}
	cp /vagrant/files/puppet-passenger/config.ru /usr/share/puppet/rack/puppetmasterd
	chown puppet:puppet /usr/share/puppet/rack/puppetmasterd/config.ru
	mkdir -p /usr/share/puppet/rack/puppetmasterd/{public,tmp}
	mkdir -p /usr/share/puppet/rack/puppetmasterd/public/{production,development}/certificate/ca
	chown -R puppet:puppet /usr/share/puppet/rack/puppetmasterd/*
	
fi

exit 0;
