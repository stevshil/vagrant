#!/bin/bash

yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install python-pip git
pip install --upgrade pip
pip install ansible

yum -y install pyOpenSSL python-cryptography python-lxml java-1.8.0-openjdk-headless httpd-tools git

cat >/etc/yum.repos.d/extras.repo <<_END_
[extras]
name=extras
baseurl=http://mirror.centos.org/centos/7/extras/x86_64
enabled=1
gpgcheck=0
_END_

yum -y install docker

cd /etc/yum.repos.d && curl -O https://storage.googleapis.com/origin-ci-test/releases/openshift/origin/master/origin.repo
cd -

git clone https://github.com/openshift/openshift-ansible
cd openshift-ansible
ansible-playbook -i inventory/hosts.localhost playbooks/prerequisites.yml
ansible-playbook -i inventory/hosts.localhost playbooks/deploy_cluster.yml
