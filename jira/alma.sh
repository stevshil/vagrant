#!/bin/bash

# Shell script to provision jira VM

dnf -y install wget
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
systemctl stop firewalld
systemctl disable firewalld

# Install jira
wget -P /tmp https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.4.2-x64.bin

chmod +x /tmp/atlassian-jira-6.4.2-x64.bin
(sleep 5; echo "o"; sleep 2; echo "1"; sleep 2; echo "i") | (sh /tmp/atlassian-jira-6.4.2-x64.bin)

exit 0
