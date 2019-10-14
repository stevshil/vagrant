#!/bin/bash

# Script to install uDeploy server and agent
# Written by Steve Shilling
# Date 25th Aug 2017

if [ -e /etc/init.d/ibmucd ]
then
	service ibmucd stop
fi

if [ -e /etc/init.d/ibmucd-agent ]
then
	service ibmucd-agent stop
fi

# Create the uDeploy extraction directory or remove if exists
if [ ! -d /opt/uDeploy ]
then
	mkdir /opt/uDeploy
else
	rm -rf /opt/uDeploy/*
fi

# Install server
cd /opt/uDeploy
if unzip /Data/uDeploy/IBM_URBANCODE_DEPLOY_6.2.5_MP_ML_.zip
then
	cp /Data/uDeploy/install.properties /opt/uDeploy/ibm-ucd-install
	export INSTALL_SERVER_DIR=/opt/ibm-ucd/server
        export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
        (sleep 2; echo -e "\n"; sleep 2; echo -e "\n") | ./install-server.sh
fi

# Install agent
cd /opt/uDeploy
if unzip /Data/uDeploy/ibm-ucd-agent.zip
then
	cp /Data/uDeploy/agent-install.properties ibm-ucd-agent-install/install.properties
	./install-agent-from-file.sh install.properties
fi

# Create control scripts
cat >/etc/init.d/ibmucd <<_END_
#!/bin/bash

### BEGIN INIT INFO
# Provides:          ibmucd
# Required-Start:
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: IBM UrbanCode Deploy control script
# Description:       Script to control UCD server and agent
### END INIT INFO

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
### BEGIN INIT INFO
# Provides:          ibmucd-agent
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: IBM UrbanCode Deploy control script
# Description:       Script to control UCD server and agent
### END INIT INFO

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

if [ ! -e /etc/init.d/ibmucd ]
then
	chmod +x /etc/init.d/ibmucd
	chkconfig --add ibmucd
	#chkconfig ibmucd on
	if ! service ibmucd status >/dev/null 2>&1
	then
        	service ibmucd start
	fi
fi

if [ ! -e /etc/init.d/ibmucd-agent ]
then
	chmod +x /etc/init.d/ibmucd-agent
	chkconfig --add ibmucd-agent
	if ! service ibmucd-agent status >/dev/null 2>&1
	then
        	service ibmucd-agent start
	fi
fi
