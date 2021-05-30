#!/bin/bash

cat >/etc/docker/daemon.json <<_END_
{
	"insecure-registries": ["192.168.10.15:5000"]
}
_END_


