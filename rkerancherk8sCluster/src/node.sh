#!/bin/bash

. config

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

systemctl disable --now ufw 2>/dev/null
systemctl disable --now apparmor 2>/dev/null
systemctl disable --now firewalld 2>/dev/null

# Kill systemd resolved
systemctl disable --now systemd-resolved.service

if [[ ! -d /home/$vmuser/.ssh ]]
then
	mkdir /home/$vmuser/.ssh
	chown $vmuser:$vmuser /home/$vmuser/.ssh
fi

if [[ ! -d /root/.ssh ]]
then
	mkdir /root/.ssh
fi

cp /var/tmp/rke_rsa /home/$vmuser/.ssh/id_rsa
cp /var/tmp/rke_rsa /root/.ssh/id_rsa
cat /var/tmp/rke_rsa.pub >>/home/$vmuser/.ssh/authorized_keys
cat /var/tmp/rke_rsa.pub >> /root/.ssh/authorized_keys
chown -R $vmuser:$vmuser /home/$vmuser/.ssh
chmod 600 /home/$vmuser/.ssh/id_rsa*

echo "To ensure networking works"
if [[ ! -d /etc/cni/net.d ]]
then
	mkdir -p /etc/cni/net.d
	touch /etc/cni/net.d/10-flannel.conflist
fi
