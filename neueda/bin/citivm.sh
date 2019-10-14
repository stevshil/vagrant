#!/bin/bash
# VM to run program for Dev and PS
# VM has it's own rpm repository and maven repo

echo "Turning off SELinux"
setenforce 0
grep -v setenforce /etc/rc.local && echo "setenforce 0" >>/etc/rc.local

# Create local repository directory
[ ! -d /var/localrepo ] && mkdir /var/localrepo
[ ! -d /var/othersw ] && mkdir /var/othersw
[ ! -d /var/eclipse ] && mkdir /var/eclipse

echo "Making networking more reliable"
if rpm -qa | grep NetworkManager >/dev/null 2>&1
then
  yum -y erase NetworkManager
  systemctl enable network
  systemctl start network
fi

# Remove Java 1.7
yum -y erase java-1.7.0-openjdk-1.7.0.141-2.6.10.1.el7_3 java-1.7.0-openjdk-headless-1.7.0.141-2.6.10.1.el7_3

# Remove the installed version of Mariadb
if rpm -qa | grep mariadb-5.5 >/dev/null 2>&1
then
	yum -y erase mariadb-libs mariadb mariadb-server
fi

if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

if ! rpm -qa | grep yum-utils | grep -v grep >/dev/null
then
	yum -y install yum-utils
fi

echo "Updating the OS"
yum -y update

# Include kernel headers for the guest additions
yum -y groupinstall "Development Tools"
yum -y install kernel-headers kernel-devel

# Install the GUI (we'll use KDE as it's closest to Windows)
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

if ! grep student /etc/passwd >/dev/null 2>&1
then
	echo "Adding Student user"
	useradd -m student
	(sleep 5; echo "neueda"; sleep 2; echo "neueda") | passwd student
fi

echo "Add student to sudoers"
echo "student ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/student
chown root:root /etc/sudoers.d/student
chmod 644 /etc/sudoers.d/student

echo "Autoenable student login"
if ! grep AutoLoginEnable /etc/gdm/custom.conf >/dev/null 2>&1
then
[ ! -d /etc/gdm ] && mkdir /etc/gdm
echo "[daemon]
AutomaticLoginEnable=true
AutomaticLogin=student

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

if [ ! -e /var/othersw/mysql-connector-java-5.1.42.tar.gz ]
then
  echo "Downloading mysql-connector-java"
  #wget -nv https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.42.tar.gz -O /var/othersw/mysql-connector-java-5.1.42.tar.gz
  cp /vagrant/files/mysql-connector-java-5.1.42.tar.gz /var/othersw/mysql-connector-java-5.1.42.tar.gz
fi

if ! grep enp0s8 /etc/rc.local
then
	echo "Enabling network interface on reboots"
	echo "/usr/sbin/ifup enp0s8" >>/etc/rc.local
fi

# Add Docker repo so we can download Docker rpm to local repo
echo "Adding Docker repo"
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Add bigger s/w repo for the downloads
echo "Adding RPMFusion repo"
yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm

# MariaDB 10 Repo
echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1.24/centos73-amd64
gpgkey=http://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" >/etc/yum.repos.d/mariadb.repo

# Google Chrome
echo "Installing Chrome"
yum -y install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

# Download all required software for standalone
echo "Downloading RPMs for local install"
for files in ctags-etags.x86_64 libreoffice-* java-1.8.0-* rabbitmq-java-client-doc.noarch rabbitmq-java-client-javadoc.noarch maven-* mysql-connector-java.noarch mysql-connector-python.noarch mysql-proxy.x86_64 mysql-proxy-devel.x86_64 mysql-utilities.noarch mariadb mariadb-devel mariadb-libs git-all python34-* docker-ce
do
	yum -y install --downloadonly --downloaddir=/var/localrepo $files
done

echo "Downloading other RPMs"
if [ ! -e /var/localrepo/mysql-workbench-community-6.3.9-1.el7.x86_64.rpm ]
then
	echo "Downloading MySQL Workbench rpm"
	wget -nv https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community-6.3.9-1.el7.x86_64.rpm -O /var/localrepo/mysql-workbench-community-6.3.9-1.el7.x86_64.rpm
	yum -y install --downloadonly --downloaddir=/var/localrepo libzip gtkmm30 libtommath libtomcrypt proj python2-ecdsa python2-crypto python2-paramiko
fi

if [ ! -e /var/localrepo/logstash-2.0.0-1.noarch.rpm ]
then
	echo "Downloading logstash rpm"
	wget -nv https://download.elastic.co/logstash/logstash/packages/centos/logstash-2.0.0-1.noarch.rpm -O /var/localrepo/logstash-2.0.0-1.noarch.rpm
fi
if [ ! -e /var/localrepo/elasticsearch-2.0.0.rpm ]
then
	echo "Downloading elasiticsearch rpm"
	wget -nv https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.0.0/elasticsearch-2.0.0.rpm -O /var/localrepo/elasticsearch-2.0.0.rpm
fi

# Eclipse plugins
if [ ! -e /var/eclipse/eclipse-neon-JEE.tar.gz ]
then
	echo "Downloading Eclipse Neon JEE"
	wget -nv 'http://ftp.fau.de/eclipse/technology/epp/downloads/release/neon/3/eclipse-jee-neon-3-linux-gtk-x86_64.tar.gz' -O /var/eclipse/eclipse-neon-JEE.tar.gz
fi
if [ ! -e /opt/eclipse ]
then
	# Install eclipse
	cd /opt
	tar xvf /var/eclipse/eclipse-neon-JEE.tar.gz
	cd -
fi
if [ ! -e /var/eclipse/pmd-eclipse-4.0.14.v20170528-1456.zip ]
then
	if [ ! -e /vagrant/files/eclipse/pmd-eclipse-4.0.14.v20170528-1456.zip ]
	then
		echo "Downloading PMD Eclipse plugin"
		wget -nv "https://dl.bintray.com/pmd/pmd-eclipse-plugin/zipped/net.sourceforge.pmd.eclipse.p2updatesite-4.0.14.v20170528-1456.zip" -O /vagrant/files/eclipse/pmd-eclipse-4.0.14.v20170528-1456.zip
	fi
	cp /vagrant/files/eclipse/pmd-eclipse-4.0.14.v20170528-1456.zip /var/eclipse/pmd-eclipse-4.0.14.v20170528-1456.zip
fi

if [ ! -e /var/eclipse/findbugs-3.0.1.20150306.zip ]
then
	echo "Downloading findbugs Eclipse plugin"
	cp /vagrant/files/eclipse/findbugs-3.0.1.20150306.zip /var/eclipse/findbugs-3.0.1.20150306.zip
fi

if [ ! -e /var/eclipse/eclemma-2.3.3.zip ]
then
	echo "Downloading eclemma Eclipse plugin"
	#wget -nv http://www.eclemma.org/download.html/eclemma-2.3.3.zip -O /var/eclipse/eclemma-2.3.3.zip
	cp /vagrant/files/eclipse/eclemma-2.3.3.zip /var/eclipse/eclemma-2.3.3.zip
fi

if [ ! -e /var/eclipse/PyDev-5.8.0.zip ]
then
	echo "Downloading PyDev Eclipse plugin"
	#wget -nv 'https://downloads.sourceforge.net/project/pydev/pydev/PyDev%205.8.0/PyDev%205.8.0.zip?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fpydev%2F&ts=1497388630&use_mirror=10gbps-io' -O /var/eclipse/PyDev-5.8.0.zip
	cp /vagrant/files/eclipse/PyDev-5.8.0.zip /var/eclipse/PyDev-5.8.0.zip
fi

# Maven

if [ ! -e /var/othersw/apache-maven-3.5.0-bin.tar.gz ]
then
	echo "Downloading Maven"
	#wget -nv http://mirror.ox.ac.uk/sites/rsync.apache.org/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz -O /var/othersw/apache-maven-3.5.0-bin.tar.gz
	wget -nv http://www-eu.apache.org/dist/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz -O /var/othersw/apache-maven-3.5.0-bin.tar.gz
fi

if [ ! -e /var/othersw/TeamCity-2017.1.2.tar.gz ]
then
	echo "Downloading TeamCity"
	wget -nv https://download.jetbrains.com/teamcity/TeamCity-2017.1.2.tar.gz -O /var/othersw/TeamCity-2017.1.2.tar.gz
fi

if [ ! -e /opt/TeamCity ]
then
  echo "Installing TeamCity"
	cd /opt
	tar xvf /var/othersw/TeamCity-2017.1.2.tar.gz
	cd -
fi

if [ ! -e /var/othersw/apache-activemq-5.14.5-bin.tar.gz ]
then
	echo "Downloading ActiveMQ"
	wget -nv http://archive.apache.org/dist/activemq/5.14.5/apache-activemq-5.14.5-bin.tar.gz -O /var/othersw/apache-activemq-5.14.5-bin.tar.gz
fi

if [ ! -e /var/othersw/wildfly-10.1.0.Final.tar.gz ]
then
	echo "Downloading Wildfly"
	wget -nv http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.tar.gz -O /var/othersw/wildfly-10.1.0.Final.tar.gz
fi

if [ ! -e /var/othersw/kibana-4.2.0-linux-x64.tar.gz ]
then
	echo "Downloading Kibana"
	wget -nv https://download.elastic.co/kibana/kibana/kibana-4.2.0-linux-x64.tar.gz -O /var/othersw/kibana-4.2.0-linux-x64.tar.gz
fi

echo "Backing up all network repos to /etc/oldrepos"
[ ! -d /etc/oldrepos ] && mkdir /etc/oldrepos && cp /etc/yum.repos.d/* /etc/oldrepos

echo "Setting local repo"
echo '[local]
name=CentOS-$releasever - Local Repo
baseurl=file:///var/localrepo/
gpgcheck=0
enabled=1' >/etc/yum.repos.d/local.repo

# Download Oracle Java JDK
if [ ! -e /vagrant/files/jdk-8u131-linux-x64.rpm ]
then
  echo "Downloading Oracle Java JDK"
  wget -nv 'https://www.dropbox.com/s/lqqp8zjc1ibmk8e/jdk-8u131-linux-x64.rpm?dl=0' -O /var/localrepo/jdk-8u131-linux-x64.rpm
fi

if [ ! -e /var/localrepo/jdk-8u131-linux-x64.rpm ]
then
  cp /vagrant/files/jdk-8u131-linux-x64.rpm /var/localrepo/jdk-8u131-linux-x64.rpm
fi

cd /var/localrepo
createrepo --workers 4 .

if [ ! -e /home/student/maven-m2.zip ]
then
	echo "Downloading local maven repo files"
	wget -nv "https://www.dropbox.com/s/ib6ct23iudvs1es/maven-m2.zip?dl=0" -O /home/student/maven-m2.zip
	chown student:student /home/student/maven-m2.zip
fi

# Other preloaded software
yum -y install emacs emacs-common emacs-git emacs-gnuplot emacs-haskell-mode emacs-ledger emacs-rpm-spec-mode emacs-terminal emacs-yaml-mode evince libreoffice libreoffice-base libreoffice-calc libreoffice-core libreoffice-draw libreoffice-filters libreoffice-graphicfilter libreoffice-impress libreoffice-langpack-en libreoffice-math libreoffice-pdfimport libreoffice-TexMaths libreoffice-writer libreoffice-xsltfilter mariadb mariadb-server mariadb-devel mariadb-libs git-all python34 mysql-workbench-community

# Oracle JDK to use Oracle's JMC
# Remove Open JDK 1.8
# yum -y erase java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-headless.x86_64
# Can't erase java-1.8.0 as Open Office won't install

if ! rpm -qa | grep -q jdk1.8.0_131
then
	echo "Installing Oracle JDK"
  yum -y install jdk-8u131-linux-x64.rpm
fi

# Set JAVA_HOME for Oracle JDK

if [[ -e /etc/profile ]] && ! grep -q JAVA_HOME /etc/profile
then
	echo "Setting JAVA_HOME"
    echo  -e '\nexport JAVA_HOME=/usr/java/default' >>/etc/profile
fi

# Once MySQL has been updated we need to add the user account
systemctl enable mariadb
systemctl start mariadb
mysql -e "
create user 'student'@'%' IDENTIFIED BY 'neueda';
create user 'student'@'localhost' IDENTIFIED BY 'neueda';
GRANT ALL PRIVILEGES ON *.* TO 'student'@'%' IDENTIFIED BY 'neueda';
GRANT ALL PRIVILEGES ON *.* TO 'student'@'localhost' IDENTIFIED BY 'neueda';
set password for 'root'@'localhost' = password('root');"

if ! grep -q 'setxkbmap' /home/student/.bash_profile
then
	echo "Adding GB keyboard as default"
    echo -e '\nsetxkbmap gb' >>/home/student/.bash_profile
fi

echo "Configuring ITRS Desktop for Linux"
if ! ls /etc/yum.repos.d/playon* >/dev/null 2>&1
then
	yum -y install http://rpm.playonlinux.com/playonlinux-yum-4-1.noarch.rpm
fi

# playonlinux require nc
if ! which nc >/dev/null 2>&1
then
	yum -y install nmap-ncat
fi

if ! rpm -qa | grep mesa | grep i686 >/dev/null 2>&1
then
	yum -y install mesa-libGL.i686 mesa-dri-drivers.i686
fi

if ! which playonlinux >/dev/null 2>&1
then
	yum -y install playonlinux
fi

echo "Adding ITRS Desktop"
if [ ! -e /vagrant/files/ITRS/pol-ITRS.tgz ]
then
	wget https://www.dropbox.com/s/up6adqf3qlvd390/pol-ITRS.tgz?dl=0 -O /vagrant/files/ITRS/pol-ITRS.tgz
fi

if [ ! -d /home/student/.PlayOnLinux/wineprefix/itrs ]
then
	cd /home/student
	tar xvf /vagrant/files/pol-ITRS.tgz
	chown -R student:student .PlayOnLinux
	cd -
fi

echo "Reboot the VM to finalise the installation"

exit 0;
