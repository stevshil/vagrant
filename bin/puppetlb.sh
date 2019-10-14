#!/bin/bash
# VM to run Puppet Cert Auth
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

setenforce 0

if ! grep student /etc/passwd >/dev/null 2>&1
then
	useradd -m student
	(sleep 5; echo "secret"; sleep 2; echo "secret") | passwd student
	systemctl stop firewalld
	systemctl disable firewalld
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
fi

#yum -y update
if ! rpm -qa | grep rpmfusion >/dev/null 2>&1 
then
	yum -y install sharutils http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm
fi

if ! rpm -qa | grep puppet >/dev/null 2>&1
then
	#yum -y install curl-devel ruby-devel httpd-devel apr-devel apr-util-devel openssl-devel zlib-devel
	yum -y install curl-devel haproxy openssl-devel

	echo "192.168.18.100	puppetmaster.training.local puppetmaster
192.168.18.12	puppetmaster-1.training.local puppetworker
192.168.18.11	puppetmaster-2.training.local puppetsrv
192.168.18.10	puppetca-1.training.local puppetca-1" >>/etc/hosts

cat <<_END_ >/etc/haproxy/haproxy.cfg
global
  chroot /var/lib/haproxy
  daemon
  group haproxy
  log /dev/log	local0 notice
  maxconn 4000
  pidfile /var/run/haproxy.pid
  #stats socket /var/lib/haproxy/stats mode 660 level admin
  user haproxy

defaults
  log global
  maxconn 8000
  option redispatch
  retries 3
  #stats enable
  timeout http-request 10s
  timeout queue 1m
  timeout connect 10s
  timeout client 1m
  timeout server 1m
  timeout check 10s

listen puppet
  bind 192.168.18.100:8140
  mode tcp
  balance source
  option ssl-hello-chk
  timeout client 1000000
  timeout server 1000000
  server puppetmaster-1.training.local puppetmaster-1.training.local:8140 check
  server puppetmaster-2.training.local puppetmaster-2.training.local:8140 check
_END_

	echo "setenforce 0" >>/etc/rc.local

fi

chkconfig haproxy on
service haproxy start

exit 0;
