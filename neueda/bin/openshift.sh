#!/bin/bash

# Author: Steve Shilling
# Date: 21st May 2018
# Automates the installation of OpenShift using Ansible playbook
# Taken from https://github.com/openshift/openshift-ansible
# Installs OpenShift onto RHEL 7.5

# Install Ansible
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install python-pip git
pip install --upgrade pip
# May need to log out and back in after this to get pip back
pip install ansible

# Install Docker
yum -y install git pyOpenSSL python-cryptography python-lxml
cat >/etc/yum.repos.d/extras.repo <<_END_
[extras]
name=extras
baseurl=http://mirror.centos.org/centos/7/extras/x86_64
enabled=1
gpgcheck=0
_END_
yum -y install docker

# Install OpenShift
cd /etc/yum.repos.d && curl -O https://storage.googleapis.com/origin-ci-test/releases/openshift/origin/master/origin.repo
cd -

git clone https://github.com/openshift/openshift-ansible.git
cd openshift-ansible
ansible-playbook -i inventory/hosts.localhost playbooks/prerequisites.yml
ansible-playbook -i inventory/hosts.localhost playbooks/deploy_cluster.yml
