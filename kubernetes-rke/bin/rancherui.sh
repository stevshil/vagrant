#!/bin/bash

# Remove podman
dnf -y erase podman buildah

# Install docker
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io
usermod -G docker vagrant
systemctl enable --now docker.service

rm -f /etc/resolv.conf

if [[ -n $YOURDNS ]]
then
  echo "Setting DNS resolver"
  echo -e "nameserver $YOURDNS\nsearch $YOURDOMAIN" >/etc/resolv.conf
  sed -i '/\[main\]/a\dns=none' /etc/NetworkManager/NetworkManager.conf
fi

# Change DNS
echo "nameserver 192.168.56.82
search localdomain" >/etc/resolv.conf

# Start Rancher web UI manager
docker run -d --restart=unless-stopped -p 1180:80 -p 2443:443 --name=rancherui --privileged rancher/rancher:v2.5-head
