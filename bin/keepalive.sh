#!/bin/bash

sudo yum -y install keepalived httpd
service network restart

if ifconfig | grep 10.0.0.210 >/dev/null 2>&1
then

echo "
vrrp_instance VI_1 {
	state MASTER
	interface enp0s8
	virtual_router_id 51
	priority 100
	advert_int 1
	virtual_ipaddress {
		10.0.0.100
	}
}" >/etc/keepalived/keepalived.conf

fi

if ifconfig | grep 10.0.0.200 >/dev/null 2>&1
then

echo "
vrrp_instance VI_1 {
	state MASTER
	interface enp0s8
	virtual_router_id 51
	priority 150
	advert_int 1
	virtual_ipaddress {
		10.0.0.100
	}
}" >/etc/keepalived/keepalived.conf

fi

echo "Hello world" >/var/www/html/index.html

if grep -v ip_nonlocal_bind /etc/sysctl.conf >/dev/null 2>&1
then
	echo "net.ipv4.ip_nonlocal_bind = 1" >>/etc/sysctl.conf
	sysctl -p
fi

service httpd start
service keepalived start
