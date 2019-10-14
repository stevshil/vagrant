#!/bin/bash
echo "Disable SELinux"
setenforce 0
grep -v setenforce /etc/rc.local && echo "setenforce 0" >>/etc/rc.local

if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null 2>&1
then
        yum -y install deltarpm
fi

if ! rpm -qa | grep yum-utils | grep -v grep >/dev/null
then
	yum -y install yum-utils
fi

echo "Removing NetworkManager and setting server style networking"
if rpm -qa | grep NetworkManager >/dev/null 2>&1
then
  yum -y erase NetworkManager
  systemctl enable network
  systemctl start network
fi

echo "Adding extra software repositories"
if ! (rpm -qa | grep rpmfusion >/dev/null 2>&1)
then
	echo "Installing extra repositories"
	yum -y install http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm >/dev/null 2>&1

	echo "Disabling firewall"
	systemctl disable firewalld
	systemctl stop firewalld
	echo "/usr/sbin/setenforce 0" >>/etc/rc.local
fi

echo "Updating O/S"
yum -y update

if ! rpm -qa | grep 'wget' >/dev/null 2>&1
then
	echo "Installing wget"
	yum -y install  wget >/dev/null 2>&1
fi

if ! rpm -qa | grep 'evince' >/dev/null 2>&1
then
	yum -y evince
fi

if ! rpm -qa | grep 'unzip' >/dev/null 2>&1
then
	echo "Installing unzip"
	yum -y install unzip >/dev/null 2>&1
fi

echo "Installing Java"
if ! rpm -qa | grep java-1.8.0-openjdk >/dev/null 2>&1
then
	yum -y install java-1.8.0-openjdk
fi

echo "Installing kernel headers for Virtualbox additions"
# Include kernel headers for the guest additions
yum -y groupinstall "Development Tools"
yum -y install kernel-headers kernel-devel

echo "Install the GUI (we'll use KDE as it's closest to Windows)"
echo "Installing GUI"
if ! ( yum grouplist | sed -n '/Installed environment/,/Available environment/p' | grep KDE >/dev/null 2>&1 )
then
        yum -y groupinstall "KDE Plasma Workspaces"
        yum -y install sharutils
        yum -y install gdm
fi

if ! rpm -qa | grep gdm >/dev/null 2>&1
then
        yum -y install gdm
        systemctl enable gdm
fi

if ! grep AutoLoginEnable /etc/gdm/custom.conf >/dev/null 2>&1
then
echo "Autoenable vagrant login"
[ ! -d /etc/gdm ] && mkdir /etc/gdm
echo "[daemon]
AutomaticLoginEnable=true
AutomaticLogin=vagrant

[security]

[xdmcp]

[greeter]

[chooser]

[debug]

" >/etc/gdm/custom.conf
fi

if ! (systemctl get-default | grep graphical.target >/dev/null 2>&1)
then
        echo "Setting GUI as default login"
        systemctl set-default graphical.target
fi

# Google Chrome
echo "Installing Chrome"
yum -y install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

if [ ! -d /opt/elk ]
then
	echo "Makin ELK directory"
	mkdir /opt/elk
fi

if [ ! -e /vagrant/files/ELK ]
then
	mkdir -p /vagrant/files/ELK
fi

if [ ! -e /vagrant/files/ELK/kibana-4.6.4-linux-x86_64.tar.gz ]
then
	echo "Downloading Kibana"
	wget https://www.elastic.co/downloads/past-releases/kibana-4-6-4 -O /vagrant/files/ELK/kibana-4.6.4-linux-x86_64.tar.gz
fi

if [ ! -d /opt/elk/kibana ]
then
	echo "Installing Kibana"
	cd /opt/elk
	tar xvf /vagrant/files/ELK/kibana-4.6.4-linux-x86_64.tar.gz
	mv kibana* kibana
	cd -
fi

if [ ! -e /vagrant/files/ELK/elasticsearch-2.4.2.tar.gz ]
then
	echo "Downloading Elasticsearch"
	wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.4.2/elasticsearch-2.4.2.tar.gz -O /vagrant/files/ELK/elasticsearch-2.4.2.tar.gz
fi

if [ ! -d /opt/elk/elasticsearch ]
then
	echo "Installing Elasticsearch"
	cd /opt/elk
	tar xvf /vagrant/files/ELK/elasticsearch-2.4.2.tar.gz
	mv elasticsearch* elasticsearch
	cd -
fi

if [ ! -e /vagrant/files/ELK/logstash-2.4.1.tar.gz ]
then
	echo "Downloading Logstash"
	wget https://download.elastic.co/logstash/logstash/logstash-2.4.1.tar.gz -O /vagrant/files/ELK/logstash-2.4.1.tar.gz
fi

if [ ! -d /opt/elk/logstash ]
then
	echo "Installing Logstash"
	cd /opt/elk
	tar xvf /vagrant/files/ELK/logstash-2.4.1.tar.gz
	mv logstash* logstash
	cd -
fi

if [ ! -e /vagrant/files/ELK/filebeat-1.3.1-x86_64.tar.gz ]
then
	wget https://download.elastic.co/beats/filebeat/filebeat-1.3.1-x86_64.tar.gz -O /vagrant/files/ELK/filebeat-1.3.1-x86_64.tar.gz
fi

if [ ! -d /opt/elk/beats ]
then
	mkdir /opt/elk/beats
fi

if [ ! -d /opt/elk/beats/filebeat ]
then
	cd /opt/elk/beats
	tar xvf /vagrant/files/ELK/filebeat-1.3.1-x86_64.tar.gz
	mv filebeat* filebeat
	cd -
fi

if [ ! -e /vagrant/files/ELK/topbeat-1.3.1-x86_64.tar.gz ]
then
	wget https://download.elastic.co/beats/topbeat/topbeat-1.3.1-x86_64.tar.gz -O /vagrant/files/ELK/topbeat-1.3.1-x86_64.tar.gz
fi

if [ ! -d /opt/elk/beats/topbeat ]
then
	cd /opt/elk/beats
	tar xvf /vagrant/files/ELK/topbeat-1.3.1-x86_64.tar.gz
	mv topbeat* topbeat
	cd -
fi

if [ ! -e /vagrant/files/ELK/Logdata.zip ]
then
	wget https://www.dropbox.com/s/eo0jrht8ajkplvp/Logdata.zip?dl=0 -O /vagrant/files/ELK/Logdata.zip
fi

if [ ! -d /opt/elk/courseware ]
then
	cd /opt/elk
	unzip /vagrant/files/ELK/Logdata.zip
	cd -
fi

cd /home/vagrant
ln -s /opt/elk /home/vagrant/course
chown -R vagrant:vagrant /opt/elk

if [ ! -d /home/vagrant/elk.pdf ]
then
	wget https://www.dropbox.com/s/lb1ym5dfu8h715y/elk.pdf?dl=0 -O /home/vagrant/elk.pdf
	chown vagrant:vagrant /home/vagrant/elk.pdf
fi

# Turn on IP forwarding to enable VirtualBox forwarding
if ! grep 'net.ipv4.ip_forward = 1' /etc/sysctl.conf >/dev/null 2>&1
then
	echo 'net.ipv4.ip_forward = 1' >>/etc/sysctl.conf
	sysctl -p /etc/sysctl.conf
fi

if ! grep -q 'setxkbmap' /home/vagrant/.bash_profile
then
	echo "Adding GB keyboard as default"
	echo -e '\nsetxkbmap gb' >>/home/vagrant/.bash_profile
fi

echo "ALL DONE AND READY TO GO"
