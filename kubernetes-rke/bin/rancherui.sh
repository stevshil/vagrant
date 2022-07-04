#!/bin/bash

# rm -f /etc/resolv.conf

# if [[ -n $YOURDNS ]]
# then
#   echo "Setting DNS resolver"
#   echo -e "nameserver $YOURDNS\nsearch $YOURDOMAIN" >/etc/resolv.conf
#   sed -i '/\[main\]/a\dns=none' /etc/NetworkManager/NetworkManager.conf
# fi

# Start Rancher web UI manager
docker run -d --restart=unless-stopped -P --name=rancherui --privileged rancher/rancher
