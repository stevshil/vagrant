#!/bin/bash

yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce docker-ce-cli containerd.io
chkconfig --add docker

cat >/etc/docker/daemon.json <<_END_
{
	"insecure-registries": ["127.0.0.1:5000"]
}
_END_
service docker start
docker run -d -p 5000:5000 --restart always --name registry registry:2
