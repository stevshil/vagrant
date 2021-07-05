#!/bin/bash

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

# Add Rancher web UI manager
docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged --name rancherui rancher/rancher:v2.5.9-rc4-linux-amd64


echo "Public IP: $(ifconfig | grep 'inet 192.168' | awk '{print $2}')"
