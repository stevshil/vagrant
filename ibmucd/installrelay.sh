#!/bin/bash

# Script to install agent and agent relay on the app server
# This script needs to run manually
# It requires the IP or DNS name of the uDeploy server for set up

echo -n "Please enter the uDeploy server IP of DNS name: "
read uDeploySRV
if [[ -z uDeploySRV ]]
then
	echo "Please enter a value"
	exit 1
fi

echo "Set JAVA_HOME"
if [ -z $JAVA_HOME ]
then
	export JAVA_HOME=/usr/lib/jvm/jre
fi

echo "Checking if agent file is already downloaded"
if [[ ! -e /home/ec2-user/ibm-ucd-agent.zip ]]
then
				echo "Downloading uDeploy Agent"
        wget https://www.dropbox.com/s/j5ze1xf1mdnh9s6/ibm-ucd-agent.zip?dl=0 -O /home/ec2-user/ibm-ucd-agent.zip
fi

if [[ ! -e /home/ec2-user/agent-install.properties ]]
then
	echo "Downloading Agent properties file"
	wget https://raw.githubusercontent.com/stevshil/vagrant/master/neueda/uDeployAppConfig/agent-install.properties -O /home/ec2-user/agent-install.properties
	echo "Setting unique ID for agent and name"
	UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1)
	sed -i "s,^locked/agent.id=.*,locked/agent.id=${UUID}," /home/ec2-user/agent-install.properties
	sed -i "s/7918/7916/g" /home/ec2-user/agent-install.properties
fi

echo "Checking is we need to download agent relay"
if [[ ! -e /home/ec2-user/installrelay.sh ]]
then
				echo "Downloading agent relay script"
        wget https://raw.githubusercontent.com/stevshil/vagrant/master/neueda/uDeployAppConfig/installrelay.sh -O /home/ec2-user/installrelay.sh
        chmod +x /home/ec2-user/installrelay.sh
fi

if [[ -d /opt/ibm-ucd ]]
then
        rm -rf /opt/ibm-ucd
fi

echo "Link to Java"
if [[ ! -e /usr/lib/jvm/bin ]]
then
        cd /usr/lib/jvm
        ln -s java/bin bin
fi

# The next step is manual
# /home/ec2-user/installrelay.sh

echo "Extract and install the agent"
if [[ ! -d /opt/uDeploy/agent ]]
then
        cd /opt/uDeploy
				echo "Extracting agent files"
        unzip /home/ec2-user/ibm-ucd-agent.zip
        # The following link is the agent silent install details
        # https://www.ibm.com/support/knowledgecenter/en/SS4GSP_6.1.1/com.ibm.udeploy.install.doc/topics/agent_install_silent.html
        cd ibm-ucd-agent-install
        cp /home/ec2-user/agent-install.properties install.properties
				echo "Installing agent"
        ./install-agent-from-file.sh install.properties
fi

echo "Creating agent control script"
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

chmod +x /etc/init.d/ibmucd-agent
echo "Adding script to start up and starting"
chkconfig --add ibmucd-agent
if ! service ibmucd-agent status >/dev/null 2>&1
then
        service ibmucd-agent start
fi

echo "Remove existing relay configuration"
if [[ -d /opt/uDeploy/agent-relay-install ]]
then
	kill `ps -ef | grep agentrelay | awk '{print $2}'`
	rm -rf /opt/uDeploy/agent-relay-install
fi

cd /opt/uDeploy
if [[ ! -e /home/ec2-user/agent-relay.zip ]]
then
	echo "Copying the agent relay file"
	wget https://www.dropbox.com/s/069rno7v8axjtn5/agent-relay.zip?dl=0 -O /home/ec2-user/agent-relay.zip
fi

echo "Extract the agent relay software"
unzip /home/ec2-user/agent-relay.zip
cd agent-relay-install

echo "Download agent relay properties file"
wget https://raw.githubusercontent.com/stevshil/vagrant/master/neueda/uDeployAppConfig/agentrelay.install.properties -O agentrelay.install.properties

echo "Set the uDeploy server in the properties file"
sed -i "s/MYHOST/$uDeploySRV/" agentrelay.install.properties
if  ! hostname -l >/dev/null 2>&1
then
	myname=$(hostname)
else
	myname=$(hostname -l)
fi
sed -i "s/^agentrelay.jms_proxy.name=.*/agentrelay.jms_proxy.name=$myname/" agentrelay.install.properties
echo "Installing the relay"
./install-silent.sh agentrelay.install.properties


echo "Create agent relay control script"
cat >/etc/init.d/ibmucd-relay <<_END_
#!/bin/bash

#description: IBM uDeploy Agent Relay control script
#chkconfig: 2345 99 99

cd /opt/ibm-ucd/agentrelay

case \$1 in
  'start')
     bin/agentrelay start
     ;;
  'stop')
     #bin/agentrelay stop
     kill `ps -ef | grep agentrelay | awk '{print $2}'`
     rm -f /opt/ibm-ucd/agentrelay/var/shutdown
     ;;
  'status')
     if ! bin/agentrelay status 2>&1
     then
       ps -ef | grep 'ibm-ucd.*agentrelay' | grep -v grep
     fi
     ;;
  *)
     echo "I'm sorry I don't understand that option"
     ;;
esac
_END_

echo "Add control script to start up and start the relay"
chmod +x /etc/init.d/ibmucd-relay
chkconfig --add ibmucd-relay
service ibmucd-relay start
