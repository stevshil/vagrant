#!/bin/bash

if hostname | grep '^rhel' >/dev/null 2>&1
then
	if ! grep 'service network restart' /etc/rc.local >/dev/null 2>&1
	then
		echo "service network restart" >>/etc/rc.local
	fi
	service network restart
	exit 0
fi

if ! ls /etc/yum.repos.d/*rpmfusion* >/dev/null 2>&1
then
	yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm
fi

if ! rpm -qa | grep ansible >/dev/null 2>&1
then
	yum -y install ansible
fi

if ! grep 'service network restart' /etc/rc.local
then
	echo "service network restart" >>/etc/rc.local
fi

service network restart

if [[ ! -d /root/.ssh ]]
then
	mkdir /root/.ssh
fi

if [[ ! -e /root/.ssh/config ]]
then
	echo "Host *
	StrictHostKeyChecking=no
">/root/.ssh/config
	chmod 600 /root/.ssh/config
fi

cp /vagrant/ansible/files/al.id_rsa /home/vagrant/.ssh/id_rsa
chmod 600 /home/vagrant/.ssh/id_rsa

cd /vagrant/ansible
# Ensure we use the hosts without keys file
rm hosts
cp hosts-nokey hosts

(sleep 2; echo vagrant) | ansible-playbook -k -i "hosts" sshkeys.yml

# Now keys have been copied
rm hosts
cp hosts-keys hosts

ansible-playbook -i "hosts" site.yml
