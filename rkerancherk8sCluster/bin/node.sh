#!/bin/bash

if [[ ! -d /home/vagrant/.ssh ]]
then
	mkdir /home/vagrant/.ssh
	chown vagrant:vagrant /home/vagrant/.ssh
fi

if [[ ! -e /home/vagrant/.ssh/id_rsa ]]
then
	cp /vagrant/files/rke_rsa /home/vagrant/.ssh/id_rsa
	cat /vagrant/files/rke_rsa.pub >>/home/vagrant/.ssh/authorized_keys
	chown -R vagrant:vagrant /home/vagrant/.ssh
	chmod 600 /home/vagrant/.ssh/id_rsa*
fi


apt-get -y update
apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get -y update
apt-get -y install docker-ce docker-ce-cli containerd.io jq

usermod -G docker vagrant
