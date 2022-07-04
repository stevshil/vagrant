#!/bin/bash

# Remove existing docker
apt-get update
apt -y remove docker docker-engine docker.io containerd runc 2>/dev/null
apt -y install apt-transport-https ca-certificates curl software-properties-common

# Configure docker for all systems
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update repo meta data
apt-get update
apt-cache policy docker-ce
apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin wget
usermod -g docker vagrant
cp /vagrant/files/k8s /home/vagrant/.ssh/id_rsa
cp /vagrant/files/k8s.pub /home/vagrant/.ssh/id_rsa.pub
cp /vagrant/files/ssh_config /home/vagrant/.ssh/config
cp /vagrant/files/etc_hosts /etc/hosts
chmod 600 /home/vagrant/.ssh/id_rsa
chown vagrant:vagrant /home/vagrant/.ssh/*
cat /home/vagrant/.ssh/id_rsa.pub >>/home/vagrant/.ssh/authorized_keys

# Enable private docker registry
echo '{
    "insecure-registries": ["http://10.0.0.82:5000"]
}' >/etc/docker/daemon.json

if ! systemctl restart docker.service
then
    systemctl start docker.service
fi