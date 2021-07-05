#!/bin/bash

vmuser=vagrant
YOURGW="192.168.10.1"

if [[ -e /etc/lsb-release ]]
then
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt-get -y update
	apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release wget
	apt-get -y install docker-ce docker-ce-cli containerd.io jq
else
	if which dnf >/dev/null 2>&1
	then
		instcmd=dnf
	else
		instcmd=yum
	fi
	$instcmd config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	$instcmd -y remove podman buildah 2>/dev/null
	$instcmd -y install docker-ce docker-ce-cli containerd.io wget net-tools
	systemctl enable --now docker.service
fi

usermod -aG docker $vmuser

cp -f /vagrant/files/etc_hosts /etc/hosts

systemctl disable --now ufw 2>/dev/null
systemctl disable --now apparmor 2>/dev/null
systemctl disable --now firewalld 2>/dev/null

# Kill systemd resolved
systemctl disable --now systemd-resolved.service

rm -f /etc/resolv.conf
cp -f /vagrant/files/resolv.conf /etc/resolv.conf

# Set root password
(sleep 2; echo "secret123"; sleep 2; echo "secret123") | passwd root

if [[ ! -d /home/$vmuser/.ssh ]]
then
	mkdir /home/$vmuser/.ssh
	chown $vmuser:$vmuser /home/$vmuser/.ssh
fi

if [[ ! -d /root/.ssh ]]
then
	mkdir /root/.ssh
fi

cp /vagrant/files/rke_rsa /home/$vmuser/.ssh/id_rsa
cp /vagrant/files/rke_rsa /root/.ssh/id_rsa
cat /vagrant/files/rke_rsa.pub >>/home/$vmuser/.ssh/authorized_keys
cat /vagrant/files/rke_rsa.pub >> /root/.ssh/authorized_keys
chown -R $vmuser:$vmuser /home/$vmuser/.ssh
chmod 600 /home/$vmuser/.ssh/id_rsa*

echo "To ensure networking works"
if [[ ! -d /etc/cni/net.d ]]
then
	mkdir -p /etc/cni/net.d
	touch /etc/cni/net.d/10-flannel.conflist
fi

if [[ $vmuser == "vagrant" ]]
then
	# Finally disable the NAT network so we only have the public, this is only required for vagrant
	sed -i 's/^ONBOOT.*/ONBOOT=no/' /etc/sysconfig/network-scripts/ifcfg-enp0s3
	# ifconfig enp0s3 down
	echo "default via $YOURGW dev enp0s8" >/etc/sysconfig/network
	init 6 # To get networking sorted
fi
