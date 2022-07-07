#!/bin/bash

mkdir -p /dns/{etc,var_named}
cp /vagrant/files/dns/etc/* /dns/etc/
cp /vagrant/files/dns/var_named/* /dns/var_named/

rm -f /etc/resolv.conf

echo "Setting DNS resolver"
if systemctl status NetworkManager >/dev/null 2>&1
then
    sed -i '/\[main\]/a\dns=none' /etc/NetworkManager/NetworkManager.conf
    systemctl restart NetworkManager
else
    systemctl disable --now systemd-resolved.service
    systemctl disable --now 
fi
echo -e "nameserver 8.8.8.8\n" >/etc/resolv.conf

docker run -itd --restart=always \
            -m 200m -p53:53/tcp -p53:53/udp \
            -v /dns/etc:/etc/mydns \
            -v /dns/var_named:/var/mydns \
            --dns=127.0.0.1 --name=mydns steve353/dns:0.2

echo -e "nameserver 192.168.56.82\nsearch 192.168.56.82" >/etc/resolv.conf