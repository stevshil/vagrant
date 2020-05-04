#!/bin/bash

# yum -y update

# This version installs Jenkins
# Adds the admin user with password secret from XML template
# Addes a single job through the API

# Check if Jenkins is already running
if rpm -qa | grep jenkins >/dev/null 2>&1
then
	service jenkins stop >/dev/null 2>&1
	>/var/log/jenkins/jenkins.log
fi

yum -y install java wget
if [[ ! -d /etc/yum.repos.d/jenkins.repo ]]
then
	wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
	rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
	#sed -i '/gpgcheck/d' /etc/yum.repos.d/jenkins.repo
	yum -y install jenkins
fi
#tar xvf /vagrant/files/jenkins-parts.tgz

# Start jenkins to get the directories
echo "Starting Jenkins for the first time"
service jenkins start
echo "Waiting for Jenkins"
until grep "INFO: Started @" /var/log/jenkins/jenkins.log >/dev/null 2>&1
do
	echo -n "."
	sleep 15
done
echo ""

echo "Stop Jenkins to add admin user"
service jenkins stop
cd /var/lib/jenkins

echo "Adding admin user"
[[ ! -d /var/lib/jenkins/users/admin ]] && mkdir /var/lib/jenkins/users/admin
cp -f /vagrant/files/admin-config.xml /var/lib/jenkins/users/admin/config.xml
chown -R jenkins:jenkins /var/lib/jenkins/users/admin

echo "Starting Jenkins"
>/var/log/jenkins/jenkins.log
service jenkins start
until grep "INFO: Started @" /var/log/jenkins/jenkins.log >/dev/null 2>&1
do
	echo -n "."
	sleep 15
done
echo ""

echo "Installing plugins"
cd /vagrant/files
export jenkinsURL=localhost:8080
token=$(./getAPIToken)
echo "Token: $token"
CRUMB=$(curl -s "http://${jenkinsURL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" -u admin:${token})
echo "Crumb: $CRUMB"

# Need to make the plugins install automatically
if ! curl -sX POST http://${jenkinsURL}/pluginManager/installPlugins -u admin:${token} -H "$CRUMB" -H "Accept-Encoding: gzip, deflate" -H "Content-Type: application/json" -H "X-Requested-With: XMLHttpRequest" --data "@installPlugins.json"
then
	echo "Failed to install plugins automatically" 1>&2
	exit 1
fi

echo "Creating first job"
cd /vagrant/files
./createJob hello_world

#systemctl restart jenkins.service
# service jenkins start
