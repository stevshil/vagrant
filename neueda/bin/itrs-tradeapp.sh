#!/bin/bash
# VM to run Geneos ITRS server for training
if rpm -qa | grep NetworkManager >/dev/null 2>&1
then
  yum -y erase NetworkManager NetworkManager-libnm
  systemctl enable network
  systemctl start network
fi

if ! grep "net.ipv4.ip_forward = 1" /etc/sysctl.conf >/dev/null 2>&1
then
	echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.conf
fi

if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

if ! rpm -qa | grep yum-utils | grep -v grep >/dev/null
then
	yum -y install yum-utils mysql
fi

if [ ! -e /vagrant/files/ITRS/mysql-connector-c-shared-6.1.10-1.el7.x86_64.rpm ]
then
  wget https://dev.mysql.com/get/Downloads/Connector-C/mysql-connector-c-shared-6.1.10-1.el7.x86_64.rpm
	yum -y install mysql-connector-c-shared-6.1.10-1.el7.x86_64.rpm
  cd /usr/lib64
  ln -s libmysqlclient.so libmysqlclient_r.so
  rm /home/vagrant/mysql-connector-c-shared-6.1.10-1.el7.x86_64.rpm
  cd
fi
if ! rpm -qa | grep java-1.8.0-openjdk | grep -v grep >/dev/null
then
	yum -y install java-1.8.0-openjdk
fi

if [ ! -e /vagrant/files/jdk-8u131-linux-x64.rpm ]
then
  echo "Downloading Oracle Java JDK"
  wget -nv 'https://www.dropbox.com/s/lqqp8zjc1ibmk8e/jdk-8u131-linux-x64.rpm?dl=0' -O /var/localrepo/jdk-8u131-linux-x64.rpm
fi

if ! rpm -qa | grep jdk1.8.0_131-1.8.0_131-fcs.x86_64 >/dev/null
then
	yum -y install /var/localrepo/jdk-8u131-linux-x64.rpm
fi

setenforce 0

if ! grep enp0s8 /etc/rc.local
then
	echo "/usr/sbin/ifup enp0s8" >>/etc/rc.local
fi

# Set up hosts file for docker instances
if ! grep mysql /etc/hosts >/dev/null 2>&1
then
	echo "127.0.0.1 mysql.server activemq.server" >>/etc/hosts
fi

if ! grep student /etc/passwd >/dev/null 2>&1
then
	useradd -m student
	(sleep 5; echo "secret"; sleep 2; echo "secret") | passwd student
fi

cd /vagrant/files/ITRS
if [ ! -e /vagrant/files/ITRS/geneos-gateway-4.1.0.linux-x64.tar.gz ]
then
	if ! wget https://www.dropbox.com/s/y82sg3ky5pce715/geneos-gateway-4.1.0.linux-x64.tar.gz?dl=0 -O geneos-gateway-4.1.0.linux-x64.tar.gz
  then
    echo "Failed to get Gateway server file" 1>&2
    exit 1
  fi
fi

if [ ! -e /vagrant/files/ITRS/geneos-netprobe-4.1.0.linux-x64.tar.gz ]
then
  if ! wget https://www.dropbox.com/s/0l3wbswee5ydc2z/geneos-netprobe-4.1.0.linux-x64.tar.gz?dl=0 -O geneos-netprobe-4.1.0.linux-x64.tar.gz
  then
    echo "Failed to get Netprobe software" 1>&2
    exit 2
  fi
fi
cd

if [ ! -d /opt/itrs ]
then
  mkdir -p /opt/itrs
  cd /opt/itrs
  if [ ! -d /opt/itrs/gateway ]
  then
    tar xvf /vagrant/files/ITRS/geneos-gateway-4.1.0.linux-x64.tar.gz
  fi
  if [ ! -d /opt/itrs/netprobe ]
  then
    tar xvf /vagrant/files/ITRS/geneos-netprobe-4.1.0.linux-x64.tar.gz
  fi

  if [[ ! -e /opt/itrs/gateway/gateway.setup.xml ]]
  then
    cp /vagrant/files/ITRS/gateway.setup.xml /opt/itrs/gateway
  fi

	# Copy license file
	cp /vagrant/files/ITRS/gateway2.lic.tmp /opt/itrs/gateway/gateway2.lic.tmp
	systemctl stop firewalld
	systemctl disable firewalld
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

echo "#!/bin/sh
# Start up ITRS services
# chkconfig: 35 99 99
# description: ITRS service start up

case \$1 in
	'start' )
		# Stop the vboxadd service and set time backward
		service vboxadd-service stop
		#dateString=`date +'05%d%H%M2014'`
		#date $dateString
		ldconfig /opt/itrs/geneos /opt/itrs/netprobe /usr/lib
    export JAVA_HOME=/usr/lib/jvm/jre

		cd /opt/itrs/gateway
		./gateway2.linux_64 -licence gateway2.lic.tmp -log gateway2.log &
		sleep 10
		cd ../netprobe
    export LOG_FILENAME=/opt/itrs/netprobe/netprobe.log
		./netprobe.linux_64 -port 55803 &
		;;
	'stop' )
		kill -9 \$(ps -ef | egrep 'gateway2.linux_64|netprobe.linux_64' | grep -v egrep | awk '{print \$2}')
		;;
esac
" > /etc/init.d/itrs

	chmod +x /etc/init.d/itrs
	chkconfig itrs on
	service itrs start
  cd /opt/itrs/netprobe
  ln -s $(find / -name libjvm.so | grep -v docker | tail -1)
  ln -s $(find / -name tzdb.dat | grep -v docker | tail -1)
fi

# Add Docker to be able to run the trading app with MySQL and ActiveMQ as Docker containers
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce
systemctl start docker
systemctl enable docker
usermod -G docker vagrant

# Download app files
[[ ! -d /opt/trade-app ]] && mkdir /opt/trade-app
if [[ ! -e /vagrant/files/ITRS/mysql-connector-java-5.1.42.tar.gz ]]
then
	wget 'https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.42.tar.gz' -O /vagrant/files/ITRS/mysql-connector-java-5.1.42.tar.gz
	cd /opt/trade-app
	tar xvf /vagrant/files/ITRS/mysql-connector-java-5.1.42.tar.gz
	cd -
fi

if [[ ! -e /vagrant/files/ITRS/trade-app-0.1.0.jar ]]
then
	wget https://www.dropbox.com/s/7ncvrkwle7wx4of/trade-app-0.1.0.jar?dl=0 -O /vagrant/files/ITRS/trade-app-0.1.0.jar
fi

cp /vagrant/files/runapp /vagrant/files/ITRS/trade-app-0.1.0.jar /opt/trade-app
chmod +x /opt/trade-app/runapp

# Run tradeapp manually by logging in to server
# /opt/trade-app/runapp

# Add logstash so we can connect to ELK VM
if ! rpm -qa | grep logstash >/dev/null 2>&1
then
        yum -y install https://download.elastic.co/logstash/logstash/packages/centos/logstash-2.0.0-1.noarch.rpm

	# Configure for ELK server
	if [ ! -e /etc/logstash/conf.d/logstash.conf ]
	then
		echo "input {
        file {
                path => [ '/var/log/messages', '/var/log/syslog' ]
                type => 'syslog'
                start_position => beginning
        }
}

output {
        elasticsearch {
                hosts => [ '192.168.1.150:9200' ]
        }
}
" >/etc/logstash/conf.d/logstash.conf
	fi

systemctl enable logstash
systemctl start logstash

fi

exit 0;
