#!/bin/bash

systemctl disable --now ufw
systemctl disable --now apparmor
systemctl disable --now firewalld

# # Kill systemd resolved
# systemctl disable --now systemd-resolved.service

# rm -f /etc/resolv.conf
# echo -e "nameserver $YOURDNS\nsearch $YOURDOMAIN" >/etc/resolv.conf

if [[ -e /etc/lsb-release ]]
then
	instcmd=apt-get
	apt-get -y update
else
	if which dnf >/dev/null 2>&1
	then
		instcmd=dnf
	else
		instcmd=yum
	fi
fi

$instcmd -y install haproxy
cp /vagrant/files/proxy/haproxy.cfg /etc/haproxy/haproxy.cfg

systemctl enable --now haproxy
systemctl restart haproxy
