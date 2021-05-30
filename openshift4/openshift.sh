#!/bin/bash

cd /usr/share
tar xvf /srv/openshift4/crc-linux-amd64.tar.xz
ln -s /usr/share/crc-linux-1.19.0-amd64/crc /bin/crc
sudo -u vagrant crc setup
# crc start

# Useful commands
# eval $(crc oc-env)
# oc login -u developer -p developer
