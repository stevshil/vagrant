#!/bin/bash
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

# Install extra repos
if ! (rpm -qa | grep rpmfusion >/dev/null 2>&1)
then
	yum -y install http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm
fi

# Install wget, java and unzip
if ! ( rpm -qa | grep java-1.8.0-openjdk >/dev/null 2>&1)
then
	yum -y install wget java-1.8.0-openjdk unzip
fi

# Turn off yet more annoying security, permanently
if grep -v setenforce /etc/rc.local >/dev/null 2>&1
then
		echo "/usr/sbin/setenforce 0" >>/etc/rc.local
		/usr/sbin/setenforce 0
fi

# install wildfly in /opt
if ! ( ls -ld /opt/wildfly* >/dev/null 2>&1)
then
	# Download Wildfly
	if ! ( ls -dl /tmp/wildfly* >/dev/null 2>&1 )
	then
		wget -P /tmp http://download.jboss.org/wildfly/8.2.1.Final/wildfly-8.2.1.Final.zip
	fi
	cd /opt
	unzip /tmp/wildfly-8.2.1.Final.zip
fi

# Create the start/stop file
if [[ ! -e /etc/init.d/wildfly ]]
then
	echo "#!/bin/bash
#description: JBoss start stop script
#chkconfig: 35 99 99
case \$1 in
	start)	nohup /opt/wildfly-8.2.1.Final/bin/standalone.sh >>/var/log/wildfly &
			;;
	stop)	kill \$(ps -ef | grep standalone | grep -v grep | awk '{print \$2}')
			;;
esac" >/etc/init.d/wildfly

	chmod +x /etc/init.d/wildfly
fi

# Change where JBoss runs
if grep '127\.0\.0\.1' /opt/wildfly-8.2.1.Final/standalone/configuration/standalone.xml >/dev/null 2>&1
then
	sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /opt/wildfly-8.2.1.Final/standalone/configuration/standalone.xml
fi

# Turn on wildfly
if ! (ps -ef | grep wildfly | grep -v grep >/dev/null 2>&1)
then
	# Start wildfly on reboot and start it now
	chkconfig wildfly on
	if service wildfly start
	then
		echo "Starting JBoss"
	fi
fi

# Turn off the firewall
if service firewalld status >/dev/null 2>&1
then
	echo "Stopping firewall"
	systemctl disable firewalld
	systemctl stop firewalld
fi

if [ -d /vagrant/developer ]
then
	echo "Checking for artifacts"
	if ls /vagrant/developer/*.[wje]ar >/dev/null 2>&1
	then
		echo "Deploying artifact"
		cp /vagrant/developer/*.[wje]ar /opt/wildfly-8.2.1.Final/standalone/deployments
	fi
fi
