#!/bin/bash

yum -y install java-1.8.0-openjdk git
cd /opt
if [[ ! -e /opt/gerrit-2.2.2.war ]]
then
	wget https://www.gerritcodereview.com/download/gerrit-2.2.2.war
fi
if ! grep gerrit2 /etc/passwd >/dev/null 2>&1
then
	adduser gerrit2
fi

cd
if [[ ! -d /home/gerrit2/gerrit ]]
then
	sudo -u gerrit2 java -jar /opt/gerrit-2.2.2.war init --batch -d /home/gerrit2/gerrit
	sudo -u gerrit2 /home/gerrit2/gerrit/bin/gerrit.sh restart
fi
