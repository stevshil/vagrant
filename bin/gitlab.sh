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

#yum -y update
if ! rpm -qa | grep rpmfusion >/dev/null 2>&1 
then
	yum -y install sharutils http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm
fi

# Grab the rpm for gitlab once as it's huge, won't need to download if local
#if [ ! -e /vagrant/files/gitlab-7.9.1_omnibus.1-1.el6.x86_64.rpm ]
#then
	#curl -k https://downloads-packages.s3.amazonaws.com/centos-6.6/gitlab-7.9.1_omnibus.1-1.el6.x86_64.rpm >/vagrant/files/gitlab-7.9.1_omnibus.1-1.el6.x86_64.rpm
#fi

#if ! rpm -qa | grep gitlab >/dev/null 2>&1
#then
	#yum -y localinstall /vagrant/files/gitlab-7.9.1_omnibus.1-1.el6.x86_64.rpm
#fi

# Newest version of gitlab
if [ ! -e /etc/yum.repos.d/gitlab* ]
then
	curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
fi
if ! rpm -qa | grep gitlab >/dev/null 2>&1
then
	yum -y install gitlab-ce
fi

if ! rpm -qa | grep puppet >/dev/null 2>&1
then
	yum -y install puppet
fi

if [ ! -d /vagrant/puppet/modules/gitlab ]
then
	puppet module install --modulepath /vagrant/puppet/modules spuder-gitlab
	sed -i "/exec { 'download gitlab':/,/# Install gitlab with the appropriate/{s/^/#/}" install.pp
	sed -i "/Exec['download gitlab']/{s/^/#/}" install.pp
	sed -i "/source.*omnibus_file/{s/^/#/}" install.pp
	sed -i "/provider.*package_manager/{s/^/#/}" install.pp
fi



exit 0;
