#!/bin/bash

DNSIP=192.168.10.21
CIDR=$(ifconfig | grep -A3 enp0s8 | grep 'inet ' | awk '{print $2}' | awk -F. '{print $1"."$2".0.0/16"}')
IP=$(ifconfig | grep -A3 enp0s8 | grep 'inet ' | awk '{print $2}')


# Install wget and bind
yum -y install wget bind-utils

# Install docker
yum -y install yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#yum -y install docker-ce docker-ce-cli containerd.io

# Add the paas openshift repo
yum-config-manager --add-repo http://mirror.centos.org/centos/7/paas/x86_64/openshift-origin
yum-config-manager --add-repo https://mirror.its.sfu.ca/mirror/ansible/epel-7-x86_64
if grep -v gpgcheck /etc/yum.repos.d/mirror.its.sfu.ca_mirror_ansible_epel-7-x86_64.repo >/dev/null 2>&1
then
	echo "gpgcheck=0" >>/etc/yum.repos.d/mirror.its.sfu.ca_mirror_ansible_epel-7-x86_64.repo
fi
if grep -v gpgcheck /etc/yum.repos.d/mirror.centos.org_centos_7_paas_x86_64_openshift-origin.repo >/dev/null 2>&1
then
	echo "gpgcheck=0" >>/etc/yum.repos.d/mirror.centos.org_centos_7_paas_x86_64_openshift-origin.repo
fi

# Install ansible and atomic
sudo yum -y install centos-release-openshift-origin311.noarch openshift-ansible.noarch openshift-ansible-playbooks.noarch

# Set appsrv.training.local as the hostname
if grep appsrv.training.local /etc/hosts >/dev/null 2>&1
then
        if ! grep ${IP} /etc/hosts >/dev/null 2>&1
        then
                sed -i 's/.*appsrv.training.local.*//' /etc/hosts
                echo "${IP}     appsrv.training.local" >>/etc/hosts
        fi
else
        echo "${IP}     appsrv.training.local" >>/etc/hosts
fi

# Set DNS to our server
cat >/etc/resolv.conf <<_END_
nameserver $DNSIP
_END_

# Set ssh no check
echo -e "Host *\n\tStrictHostKeyChecking no" >/home/vagrant/.ssh/config
mkdir /root/.ssh
chmod 700 /root/.ssh
cp /home/vagrant/.ssh/config /root/.ssh/config

# Perform Pre-req
cp -f /vagrant/files/etc_ansible/hosts /etc/ansible/hosts
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
