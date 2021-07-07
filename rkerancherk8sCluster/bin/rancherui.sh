#!/bin/bash

. /vagrant/src/config
cp /vagrant/src/rke_rsa* /var/tmp
rm -f /etc/resolv.conf

if [[ -n $YOURDNS ]]
then
  echo "Setting DNS resolver"
  echo -e "nameserver $YOURDNS\nsearch $YOURDOMAIN" >/etc/resolv.conf
  sed -i '/\[main\]/a\dns=none' /etc/NetworkManager/NetworkManager.conf
fi

cp -f /vagrant/etc_hosts /etc/hosts

/vagrant/src/node.sh

# Start Rancher web UI manager
docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher
