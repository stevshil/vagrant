#!/bin/bash

# Automate uDeploy installation

yum -y install java-1.8.0-openjdk unzip

# Get latest TeamCity version URL
TCurl=$(curl --verbose -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36' -ksS 'https://data.services.jetbrains.com/products/download?code=TC&platform=linux' 2>&1 | awk '/Location/ { print $3 }')
TCurl=$(echo $TCurl | tr -d '\r')
TCVersion=$(basename ${TCurl})

cd /vagrant/files
if [[ ! -e /vagrant/files/${TCVersion} ]] && [[ ! -d /opt/TeamCity ]]
then
	wget "${TCurl}"
fi

if [[ ! -e /vagrant/files/uDeploy/TeamCitySourceConfig-10.910199.zip ]]
then
	wget https://www.dropbox.com/s/grnmuav6969fd6o/TeamCitySourceConfig-10.910199.zip?dl=0 -O uDeploy/TeamCitySourceConfig-10.910199.zip
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

if [ ! -d /opt/TeamCity/logs ]
then
	mkdir /opt/TeamCity/logs
fi

case \$1 in
  'start')
	cd /opt/TeamCity
	bin/startup.sh
	cd /opt/TeamCity/buildAgent
	bin/agent.sh start
	;;
  'stop')
	cd /opt/TeamCity
	bin/shutdown.sh
	cd /opt/TeamCity/buildAgent
	bin/agent.sh stop
	;;
esac
_END_

# Check VM has ec2-user
if [[ ! -d /home/ec2-user ]]
then
        if [[ ! -d /vagrant/files/home/ec2-user ]]
        then
                mkdir -p /vagrant/files/home/ec2-user
        fi
        ln -s /vagrant/files/home/ec2-user /home/ec2-user
fi

if [[ ! -e /home/ec2-user/uDeploy-install.sh ]]
then
	wget https://raw.githubusercontent.com/stevshil/vagrant/master/neueda/uDeployAppConfig/uDeploy-install.sh -O /home/ec2-user/uDeploy-install.sh
	chmod +x /home/ec2-user/uDeploy-install.sh
fi

/home/ec2-user/uDeploy-install.sh
