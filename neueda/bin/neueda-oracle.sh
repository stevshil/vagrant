#!/bin/bash
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

yum -y update

if ! ( yum grouplist | sed -n '/Installed environment/,/Available environment/p' | grep KDE >/dev/null 2>&1 )
then
	yum -y groupinstall "KDE Plasma Workspaces"
	# Add MySQL here (or maria DB, and start it
	yum -y install mariadb mariadb-libs mariadb-server
fi

if ! grep student /etc/passwd >/dev/null 2>&1
then
	useradd -m student
	(sleep 5; echo "secret"; sleep 2; echo "secret") | passwd student
fi

if ! grep AutoLoginEnable /etc/gdm/custom.conf >/dev/null 2>&1
then

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

service mariadb start
chkconfig mariadb on

if [ ! -e /vagrant/files/oracle-xe-11.2.0-1.0.x86_64.rpm.zip ]
then
	wget https://www.dropbox.com/s/d6pmmsh7z418lxk/oracle-xe-11.2.0-1.0.x86_64.rpm.zip?dl=0 -O /vagrant/files/oracle-xe-11.2.0-1.0.x86_64.rpm.zip
fi

if ! rpm -qa | grep oracle-xe >/dev/null 2>&1
then
	yum -y install /vagrant/files/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm
fi

cd /home/student

if ! (systemctl get-default | grep graphical.target >/dev/null 2>&1)
then
	systemctl set-default graphical.target
	systemctl disable firewalld
	systemctl stop firewalld
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
fi
