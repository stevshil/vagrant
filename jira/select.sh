#!/bin/bash

# Decide which script to provision with

if grep AlmaLinux /etc/redhat-release >/dev/null 2>&1
then
  /vagrant/alma.sh
else
  /vagrant/centos.sh
fi
