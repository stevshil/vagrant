#!/bin/bash


# Install Java and MySQL client
yum -y erase java-1.7.0-openjdk
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel.x86_64 mysql56

# Install Docker
yum -y install yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce

# Install Maven
[[ ! -d /vagrant/files ]] && mkdir /vagrant/files
cd /vagrant/files
[[ ! -d /opt/maven ]] && [[ ! -e /vagrant/files/apache-maven-3.5.0-bin.tar.gz ]] && wget -nv http://mirrors.gigenet.com/apache/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz
cd /opt
mkdir /opt/maven || echo '/opt/maven already exists'
[[ ! -d /opt/maven/lib ]] && [[ -e /vagrant/files/apache-maven-3.5.0-bin.tar.gz ]] && tar zxvf /vagrant/files/apache-maven-3.5.0-bin.tar.gz -C /opt/maven --strip-component=1

# Configure Maven environment
grep M2_HOME /etc/profile || echo -e 'export M2_HOME=/opt/maven\nexport M2=$M2_HOME/bin\nPATH=$M2:$PATH\n' >>/etc/profile

# Install TeamCity
cd /vagrant/files
[[ ! -d /opt/TeamCity/logs ]] && [[ ! -e /vagrant/files/TeamCity-2017.1.1.tar.gz ]] && wget -nv https://download.jetbrains.com/teamcity/TeamCity-2017.1.1.tar.gz
cd /opt
[[ ! -d /opt/TeamCity/logs ]] && tar xvf /vagrant/files/TeamCity-2017.1.1.tar.gz

# Map TeamCity BuildServer configuration to DATA directory
[[ ! -d /opt/TeamCity/DATA ]] && mkdir -p /opt/TeamCity/DATA
cd /root && ln -s /opt/TeamCity/DATA .BuildServer

# Enable TeamCity start on reboot
grep -v startup.sh /etc/rc.local && echo -e '/opt/TeamCity/bin/startup.sh\n/opt/TeamCity/buildAgent/bin/agent.sh start' >>/etc/rc.local

# Add the file that needs to be there for TeamCity to start
mkdir /opt/TeamCity/logs && touch /opt/TeamCity/logs/catalina.out

# Start Team City
[[ -e /opt/TeamCity/bin/startup.sh ]] && /opt/TeamCity/bin/startup.sh
/opt/TeamCity/buildAgent/bin/agent.sh start

# Set vagrant user to use docker
sed -i 's/\(docker.*\)/\1vagrant/' /etc/group
chkconfig docker on
/sbin/service docker start
