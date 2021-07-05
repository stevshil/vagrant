#!/bin/bash

cp -f /vagrant/files/etc_hosts /etc/hosts

systemctl disable --now ufw
systemctl disable --now apparmor

# Kill systemd resolved
systemctl disable --now systemd-resolved.service

rm -f /etc/resolv.conf
cp -f /vagrant/files/resolv.conf /etc/resolv.conf

# Set root password
(sleep 2; echo "secret123"; sleep 2; echo "secret123") | passwd root

if [[ ! -d /home/vagrant/.ssh ]]
then
	mkdir /home/vagrant/.ssh
	chown vagrant:vagrant /home/vagrant/.ssh
fi

if [[ ! -e /home/vagrant/.ssh/id_rsa ]]
then
	cp /vagrant/files/rke_rsa /home/vagrant/.ssh/id_rsa
	cp /vagrant/files/rke_rsa /root/.ssh/id_rsa
	cat /vagrant/files/rke_rsa.pub >>/home/vagrant/.ssh/authorized_keys
	cat /vagrant/files/rke_rsa.pub /root/.ssh/authorized_keys
	chown -R vagrant:vagrant /home/vagrant/.ssh
	chmod 600 /home/vagrant/.ssh/id_rsa*
fi

if [[ -e /etc/lsb-release ]]
then
	instcmd=apt-get
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
