#!/bin/bash

# Automate TeamCity Agent installation

yum -y install java-1.8.0-openjdk

# Download the TC Agent program

cat >/etc/init.d/tcagent <<_END_
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

chmod +x /etc/init.d/tcagent
chkconfig tcagent on
service tcagent start
