#!/bin/bash
# VM to run GitLab
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

if ! grep 'SELINUX=disabled' /etc/sysconfig/selinux >/dev/null 2>&1
then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
fi

if ! grep 'net.ipv4.ip_forward = 0' /etc/sysctl.conf >/dev/null 2>&1
then
	sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
fi

if [ ! -e /etc/init.d/gateway ]
then
	echo "#!/bin/bash
#description: Simple Linux router
#chkconfig: 2345 99 99
setenforce 0
echo 1 >/proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
iptables -A FORWARD -i enp0s3 -o enp0s8 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT" >/etc/init.d/gateway
	chmod +x /etc/init.d/gateway
	chkconfig --add gateway
	chkconfig gateway on
	systemctl stop firewalld
	systemctl disable firewalld
fi

#yum -y update

exit 0;
