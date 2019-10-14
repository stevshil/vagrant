#!/bin/bash
# VM to run Geneos ITRS server for training
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

yum -y update

if ! ( yum grouplist | sed -n '/Installed environment/,/Available environment/p' | grep KDE >/dev/null 2>&1 )
then
        yum -y groupinstall "KDE Plasma Workspaces"
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

if ! grep student /etc/passwd >/dev/null 2>&1
then
	useradd -m student
	(sleep 5; echo "secret"; sleep 2; echo "secret") | passwd student
	yum -y install python python-tools
	systemctl stop firewalld
	systemctl disable firewalld
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
fi

if ! ( systemctl get-default | grep graphical.target >/dev/null 2>&1)
then
	systemctl set-default graphical.target
	init 5
fi

exit 0;
