#!/bin/bash

if ! which wget >/dev/null 2>&1
then
  yum -y install wget
fi

if ! rpm -qa | grep java-1.8.0-openjdk >/dev/null 2>&1
then
  yum -y install java-1.8.0-openjdk
fi

# Download and install Wildfly
cd /tmp
if [[ ! -d /opt/wildfly-10.1.0.Final ]]
then
  wget http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.tar.gz
  cd /opt
  tar xvf /tmp/wildfly-10.1.0.Final.tar.gz
fi

# Start Wildfly
if ! ps -ef | grep -i wildfly | grep -v grep >/dev/null 2>&1
then
  cd /opt/wildfly-10.1.0.Final
  nohup bin/standalone.sh -b=0.0.0.0 &
fi

# Download Jenkins
if [[ ! -d /opt/jenkins ]]
then
  mkdir /opt/jenkins 
fi

cd /opt/jenkins
if [[ ! -e jenkins.war ]]
then
  wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war
fi

# Deploy Jenkins
cd /opt/wildfly-10.1.0.Final/standalone/deployments
if [[ ! -e jenkins.war ]]
then
  ln -s /opt/jenkins/jenkins.war
fi
