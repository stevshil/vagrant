#!/bin/bash

# Author: Steve Shilling
# Date: 21st May 2018
# Automates the installation of uDeploy agent and Relay set up scripts
# Used to build the initial image

# Automate uDeploy installation
if [[ ! -d /opt/uDeploy ]]
then
	mkdir /opt/uDeploy
fi

echo "Add the ec2-user directory if not on AWS"
if [[ ! -d /home/ec2-user ]]
then
        if [[ ! -d /vagrant/files/home/ec2-user ]]
        then
                mkdir /vagrant/files/ec2-user/home/ec2-user
        fi
        ln -s /vagrant/files/home/ec2-user /home/ec2-user
fi

echo "Installing Java"
yum -y install java-1.8.0-openjdk unzip

# echo "Checking if agent file is already downloaded"
# if [[ ! -e /home/ec2-user/ibm-ucd-agent.zip ]]
# then
# 				echo "Downloading uDeploy Agent"
#         wget https://www.dropbox.com/s/j5ze1xf1mdnh9s6/ibm-ucd-agent.zip?dl=0 -O /home/ec2-user/ibm-ucd-agent.zip
# 				echo "Downloading Agent properties file"
#         wget https://raw.githubusercontent.com/stevshil/vagrant/master/neueda/uDeployAppConfig/agent-install.properties -O /home/ec2-user/agent-install.properties
# 				echo "Setting unique ID for agent and name"
# 				UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1)
# 				sed -i "s,^locked/agent.id=.*,locked/agent.id=${UUID}," /home/ec2-user/agent-install.properties
# 				sed -i "s/7918/7916/g" /home/ec2-user/agent-install.properties
# fi
#
echo "Checking is we need to download agent relay"
if [[ ! -e /home/ec2-user/installrelay.sh ]]
then
				echo "Downloading agent relay script"
       wget https://raw.githubusercontent.com/stevshil/vagrant/master/neueda/uDeployAppConfig/installrelay.sh -O /home/ec2-user/installrelay.sh
       chmod +x /home/ec2-user/installrelay.sh
fi
#
# if [[ -d /opt/ibm-ucd ]]
# then
#         rm -rf /opt/ibm-ucd
# fi
#
# echo "Link to Java"
# if [[ ! -e /usr/lib/jvm/bin ]]
# then
#         cd /usr/lib/jvm
#         ln -s java/bin bin
# fi
#
# # The next step is manual
# # /home/ec2-user/installrelay.sh
#
# echo "Extract and install the agent"
# if [[ ! -d /opt/uDeploy/agent ]]
# then
#         cd /opt/uDeploy
# 				echo "Extracting agent files"
#         unzip /home/ec2-user/ibm-ucd-agent.zip
#         # The following link is the agent silent install details
#         # https://www.ibm.com/support/knowledgecenter/en/SS4GSP_6.1.1/com.ibm.udeploy.install.doc/topics/agent_install_silent.html
#         cd ibm-ucd-agent-install
#         cp /home/ec2-user/agent-install.properties install.properties
# 				echo "Installing agent"
#         ./install-agent-from-file.sh install.properties
# fi
#
# echo "Creating agent control script"
# cat >/etc/init.d/ibmucd-agent <<_END_
# #!/bin/bash
#
# #description: IBM uDeploy Agent control script
# #chkconfig: 2345 99 99
#
# cd /opt/ibm-ucd/agent
#
# case \$1 in
#   'start')
#      bin/agent start
#      ;;
#   'stop')
#      bin/agent stop
#      ;;
#   'status')
#      if ! bin/agent status
#      then
#        ps -ef | grep 'ibm-ucd.*agent' | grep -v grep
#      fi
#      ;;
#   *)
#      echo "I'm sorry I don't understand that option"
#      ;;
# esac
# _END_
#
# chmod +x /etc/init.d/ibmucd-agent
# echo "Adding script to start up and starting"
# chkconfig --add ibmucd-agent
# if ! service ibmucd-agent status >/dev/null 2>&1
# then
#         service ibmucd-agent start
# fi
#
# echo "Please run the Agent Relay script"
# echo "sudo /home/ec2-user/installrelay.sh <uDeploySRV IP or DNS>"
