#!/bin/bash

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
	systemctl set-default graphical.target
	init 6
fi
