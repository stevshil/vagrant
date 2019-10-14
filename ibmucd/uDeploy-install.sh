#!/bin/bash


# Add the ec2-user directory if not on AWS
if [[ ! -d /home/ec2-user ]]
then
	if [[ ! -d /vagrant/files/ec2-user ]]
	then
		mkdir /home/ec2-user
	else
		ln -s /vagrant/files/ec2-user /home/ec2-user
	fi
fi

if [[ ! -e /home/ec2-user/IBM_URBANCODE_DEPLOY_6.2.5_MP_ML_.zip ]]
then
	wget https://www.dropbox.com/s/fvzxqdif3d2bgvt/IBM_URBANCODE_DEPLOY_6.2.5_MP_ML_.zip?dl=0 -O /home/ec2-user/IBM_URBANCODE_DEPLOY_6.2.5_MP_ML_.zip
	wget https://raw.githubusercontent.com/stevshil/vagrant/master/neueda/uDeployAppConfig/install.properties -O /home/ec2-user/install.properties
fi

if [[ ! -e /home/ec2-user/ibm-ucd-agent.zip ]]
then
	wget https://www.dropbox.com/s/j5ze1xf1mdnh9s6/ibm-ucd-agent.zip?dl=0 -O /home/ec2-user/ibm-ucd-agent.zip
	wget https://raw.githubusercontent.com/stevshil/vagrant/master/neueda/uDeployAppConfig/agent-install.properties -O /home/ec2-user/agent-install.properties
	# NEED TO CHANGE the following line for each host
	#locked/agent.id=4EYR4GosM4mXLguGr08l
fi

if [[ ! -e /home/ec2-user/installrelay.sh ]]
then
	wget https://raw.githubusercontent.com/stevshil/vagrant/master/neueda/uDeployAppConfig/installrelay.sh -O /home/ec2-user/installrelay.sh
	chmod +x /home/ec2-user/installrelay.sh
fi

# Extract directory
if [[ -d /opt/uDeploy ]]
then
	rm -rf /opt/uDeploy
fi

if [[ -d /opt/ibm-ucd ]]
then
	rm -rf /opt/ibm-ucd
fi

# Link to Java
if [[ ! -e /usr/lib/jvm/bin ]]
then
	cd /usr/lib/jvm
	ln -s java/bin bin
fi

# Extract and install the server
if [[ ! -d /opt/uDeploy ]]
then
	mkdir -p /opt/uDeploy
	cd /opt/uDeploy
	unzip /home/ec2-user/IBM_URBANCODE_DEPLOY_6.2.5_MP_ML_.zip
	cd ibm-ucd-install
	# Need to review the following to auto install;
	# https://developer.ibm.com/answers/questions/15811/silent-install-of-urbancode-deploy.html
	# Run automated install
	cp /home/ec2-user/install.properties install.properties
	export INSTALL_SERVER_DIR=/opt/ibm-ucd/server
	export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
	(sleep 2; echo -e "\n"; sleep 2; echo -e "\n") | ./install-server.sh
fi

# Extract and install the agent
if [[ ! -d /opt/uDeploy/agent ]]
then
	cd /opt/uDeploy
	unzip /home/ec2-user/ibm-ucd-agent.zip
	# The following link is the agent silent install details
	# https://www.ibm.com/support/knowledgecenter/en/SS4GSP_6.1.1/com.ibm.udeploy.install.doc/topics/agent_install_silent.html
	cd ibm-ucd-agent-install
	cp /home/ec2-user/agent-install.properties install.properties
	./install-agent-from-file.sh install.properties
fi

cat >/etc/init.d/ibmucd <<_END_
#!/bin/bash

#description: IBM uDeploy control script
#chkconfig: 2345 99 99

cd /opt/ibm-ucd/server
source bin/set_env

case \$1 in
  'start')
     bin/server start
     ;;
  'stop')
     bin/server stop
     ;;
  'status')
     if ! bin/server status
     then
       ps -ef | grep 'ibm-ucd.*server' | grep -v grep
     fi
     ;;
  *)
     echo "I'm sorry I don't understand that option"
     ;;
esac
_END_

cat >/etc/init.d/ibmucd-agent <<_END_
#!/bin/bash

#description: IBM uDeploy Agent control script
#chkconfig: 2345 99 99

cd /opt/ibm-ucd/agent

case \$1 in
  'start')
     bin/agent start
     ;;
  'stop')
     bin/agent stop
     ;;
  'status')
     if ! bin/agent status
     then
       ps -ef | grep 'ibm-ucd.*agent' | grep -v grep
     fi
     ;;
  *)
     echo "I'm sorry I don't understand that option"
     ;;
esac
_END_

chmod +x /etc/init.d/ibmucd
chkconfig --add ibmucd
#chkconfig ibmucd on
if ! service ibmucd status >/dev/null 2>&1
then
	service ibmucd start
fi

chmod +x /etc/init.d/ibmucd-agent
chkconfig --add ibmucd-agent
if ! service ibmucd-agent status >/dev/null 2>&1
then
	# Don't start agent until server is running
	until grep -i 'main com.urbancode.ds.UDeployServer - IBM UrbanCode Deploy server version .* started' /opt/ibm-ucd/server/var/log/stdout
	do
		sleep 30
	done
	service ibmucd-agent start
fi

# Now install the agent relay
#/home/ec2-user/installrelay.sh
