#!/bin/bash

yum -y install bind bind-utils

rm -rf /etc/named /etc/named.rfc1912.zones

cp -f /vagrant/files/etc/named.conf /etc/named.conf
cp -f /vagrant/files/var_named/* /var/named/
cp -f /vagrant/files/etc/resolv.conf /etc/resolv.conf

service named restart
systemctl enable named
