#!/bin/bash

# Shell script to provision jira VM

if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

# Add the rpmfusion repos
if ! (rpm -qa | grep rpmfusion >/dev/null 2>&1)
then
	yum -y install http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm wget
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
	systemctl stop firewalld
	systemctl disable firewalld
fi

# Install jira
wget -P /tmp https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.4.2-x64.bin

chmod +x /tmp/atlassian-jira-6.4.2-x64.bin
(sleep 5; echo "o"; sleep 2; echo "1"; sleep 2; echo "i") | (sh /tmp/atlassian-jira-6.4.2-x64.bin)

exit 0
