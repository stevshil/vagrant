#!/bin/bash

# Automate TeamCity installation

yum -y install java-1.8.0-openjdk

# If TCVERSION not set then get lates
if [[ -z $TCVERSION ]]
then
	# Get latest TeamCity version URL
	TCurl=$(curl --verbose -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36' -ksS 'https://data.services.jetbrains.com/products/download?code=TC&platform=linux' 2>&1 | awk '/Location/ { print $3 }')
	TCurl=$(echo $TCurl | tr -d '\r')
	TCVersion=$(basename ${TCurl})
else
	TCVersion=$TCVERSION
fi

cd /vagrant/files
if [[ ! -e /vagrant/files/${TCVersion} ]] && [[ ! -d /opt/TeamCity ]]
then
	wget "${TCurl}"
fi

cd /opt
if [[ ! -d /opt/TeamCity ]]
then
	tar xvf /vagrant/files/${TCVersion}
fi

mkdir /opt/TeamCity/logs
touch /opt/TeamCity/logs/catalina.out

cat >/etc/init.d/teamcity <<_END_
#!/bin/bash

#description: TeamCity control script
#chkconfig: 2345 99 99

case \$1 in
  'start')
	/opt/TeamCity/bin/startup.sh
	;;
  'stop')
	/opt/TeamCity/bin/shutdown.sh
	;;
esac
_END_

chmod +x /etc/init.d/teamcity
chkconfig teamcity on
service teamcity start
