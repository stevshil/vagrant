#!/bin/bash

. config

if [[ ! -e /usr/local/bin/rke ]]
then
	cp /var/tmp/rke /usr/local/bin/rke
	chmod +x /usr/local/bin/rke
fi

# For RHEL linux since root does not have /usr/local/bin in path
if [[ ! -e /bin/rke ]]
then
	ln -s /usr/local/bin/rke /bin/rke
fi

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
if [[ ! -e /usr/local/bin/kubectl ]]
then
	cp /var/tmp/kubectl /usr/local/bin/kubectl
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
kubectl apply -f lbstatus.yml

# Add Rancher web UI manager
# docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher
