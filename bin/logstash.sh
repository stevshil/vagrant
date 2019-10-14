#!/bin/bash
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

if rpm -qa | grep NetworkManager >/dev/null 2>&1
then
  yum -y erase NetworkManager NetworkManager-libnm
  systemctl enable network
  systemctl start network
fi

if ! (rpm -qa | grep rpmfusion >/dev/null 2>&1)
then
	echo "Installing extra repositories"
	yum -y install http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm >/dev/null 2>&1

	echo "Disabling firewall"
	systemctl disable firewalld
	systemctl stop firewalld
	echo "/usr/sbin/setenforce 0" >>/etc/rc.local
fi

if ! rpm -qa | grep 'wget' >/dev/null 2>&1
then
	echo "Installing wget"
	yum -y install  wget >/dev/null 2>&1
fi

if ! rpm -qa | grep 'unzip' >/dev/null 2>&1
then
	echo "Installing unzip"
	yum -y install unzip >/dev/null 2>&1
fi

if ! rpm -qa | grep java-1.8.0-openjdk >/dev/null 2>&1
then
	yum -y install java-1.8.0-openjdk
fi

if ! rpm -qa | grep logstash >/dev/null 2>&1
then
	yum -y install https://download.elastic.co/logstash/logstash/packages/centos/logstash-2.0.0-1.noarch.rpm
fi

if ! rpm -qa | grep elasticsearch >/dev/null 2>&1
then
	yum -y install https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.0.0/elasticsearch-2.0.0.rpm
fi

if ! ls /opt/kibana* >/dev/null 2>&1
then
	cd /tmp
	wget https://download.elastic.co/kibana/kibana/kibana-4.2.0-linux-x64.tar.gz
	cd /opt
	tar xvf /tmp/kibana-4.2.0-linux-x64.tar.gz
	cd -
fi

# Configure apps
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
		hosts => [ 'localhost:9200' ]
	}
}
# Other examples from https://www.elastic.co/guide/en/logstash/current/config-examples.html
" >/etc/logstash/conf.d/logstash.conf
fi

if ! grep 'network.host.*localhost' /etc/elasticsearch/elasticsearch.yml >/dev/null 2>&1
then
	cd /etc/elasticsearch
	cp elasticsearch.yml elasticsearch.yml.orig
	echo "node.name: 'logstash'
node.master: true
network.bind_host: localhost
network.publish_host: localhost
">/etc/elasticsearch/elasticsearch.yml
	cd -
fi

if [ ! -e /etc/init.d/kibana ]
then
	echo "#!/bin/bash
# description: Kibana for logstash
# chkconfig: 35 99 99
case \$1 in
	start)
		nohup /opt/kibana*/bin/kibana &
		;;
	stop)
		pkill kibana
		;;
	status)
		if ! ps -ef | grep kibana | grep -v grep >/dev/null 2>&1
		then
			echo "Kibana is running"
		else
			echo "Kibana is not running"
		fi
		;;
esac" >/etc/init.d/kibana
chmod +x /etc/init.d/kibana
chkconfig --add kibana
fi

# Default login is admin/admin
setenforce 0

# Start services
if ! service logstash status >/dev/null 2>&1
then
	service logstash start
fi

if ! service elasticsearch status >/dev/null 2>&1
then
	service elasticsearch start
fi

if ! service kibana status >/dev/null 2>&1
then
	service kibana start
fi

# Make messages readable
chmod +r /var/log/messages

# Add netprobe for ITRS monitoring
if [ ! -e /vagrant/files/ITRS/geneos-netprobe-4.1.0.linux-x64.tar.gz ]
then
  if ! wget https://www.dropbox.com/s/0l3wbswee5ydc2z/geneos-netprobe-4.1.0.linux-x64.tar.gz?dl=0 -O geneos-netprobe-4.1.0.linux-x64.tar.gz
  then
    echo "Failed to get Netprobe software" 1>&2
    exit 2
  fi
fi

if [ ! -d /opt/itrs ]
then
  mkdir -p /opt/itrs
  cd /opt/itrs
  if [ ! -d /opt/itrs/netprobe ]
  then
    tar xvf /vagrant/files/ITRS/geneos-netprobe-4.1.0.linux-x64.tar.gz
  fi

echo "#!/bin/sh
# Start up ITRS services
# chkconfig: 35 99 99
# description: ITRS service start up

case \$1 in
	'start' )
		ldconfig /opt/itrs/netprobe /usr/lib
    export JAVA_HOME=/usr/lib/jvm/jre

		cd /opt/itrs/netprobe
    export LOG_FILENAME=/opt/itrs/netprobe/netprobe.log
		./netprobe.linux_64 -port 55804 &
		;;
	'stop' )
		kill -9 \$(ps -ef | egrep 'gateway2.linux_64|netprobe.linux_64' | grep -v egrep | awk '{print \$2}')
		;;
esac
" > /etc/init.d/itrs

	chmod +x /etc/init.d/itrs
	chkconfig itrs on
	service itrs start
fi
