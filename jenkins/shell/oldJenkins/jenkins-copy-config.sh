#!/bin/bash

# yum -y update

yum -y install java wget
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum -y install jenkins
cd /var/lib/jenkins
tar xvf /vagrant/files/jenkins-parts.tgz
systemctl start jenkins.service
# service jenkins start
