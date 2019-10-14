#!/bin/bash

# yum -y update

# This version installs Jenkins
# Adds the admin user with password secret from XML template
# Addes a single job through the API


yum -y install java wget
if [[ ! -d /etc/yum.repos.d/jenkins.repo ]]
then
	wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
	rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
	yum -y install jenkins
fi

# Start jenkins to get the directories
echo "Starting Jenkins for the first time"
service jenkins start

#sleep 120

echo "Adding admin user"
#[[ ! -d /var/lib/jenkins/users/admin ]] && mkdir /var/lib/jenkins/users/admin
#cp /vagrant/files/admin-config.xml /var/lib/jenkins/users/admin/config.xml
#chown -R jenkins:jenkins /var/lib/jenkins/users/admin

