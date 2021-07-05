#!/bin/bash

vmuser=vagrant

if [[ ! -e /vagrant/files/rke ]]
then
	wget https://github.com/rancher/rke/releases/download/v1.2.8/rke_linux-amd64 -O /vagrant/files/rke
fi

if [[ ! -e /usr/local/bin/rke ]]
then
	cp /vagrant/files/rke /usr/local/bin/rke
	chmod +x /usr/local/bin/rke
fi

# For RHEL linux since root does not have /usr/local/bin in path
if [[ ! -e /bin/rke ]]
then
	ln -s /usr/local/bin/rke /bin/rke
fi

IP=$(ifconfig | grep -A1 enp0s8 | grep inet | awk '{print $2}')

cp /vagrant/files/fullcluster.yml /root/cluster.yml

# This would create you a new cluster.yml file
# rke config --name cluster.yml

cd /root
pwd
# Deploy cluster
rke up

# To ensure networking works
if [[ ! -d /etc/cni/net.d ]]
then
	mkdir -p /etc/cni/net.d
	touch /etc/cni/net.d/10-flannel.conflist
fi

# Install kubectl
if [[ ! -e /vagrant/files/kubectl ]]
then
	wget "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -O /vagrant/files/kubectl
fi

if [[ ! -e /usr/local/bin/kubectl ]]
then
	cp /vagrant/files/kubectl /usr/local/bin/kubectl
	chmod +x /usr/local/bin/kubectl
fi

if [[ ! -e /bin/kubectl ]]
then
	ln -s /usr/local/bin/kubectl /bin/kubectl
fi

# Set up default login for kubectl
[[ ! -d /home/$vmuser/.kube ]] && mkdir /home/$vmuser/.kube
[[ ! -d /root/.kube ]] && mkdir /root/.kube
cp /root/kube_config_cluster.yml /home/$vmuser/.kube/config
chown -R $vmuser:$vmuser /home/$vmuser/.kube
cp /root/kube_config_cluster.yml /root/.kube/config

# Deploy lb status for haproxy
kubectl apply -f /vagrant/files/lbcheck/lbstatus.yml

# Add Rancher web UI manager
# docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher

echo "Public IP: $(ifconfig | grep 'inet 192.168' | awk '{print $2}')"
