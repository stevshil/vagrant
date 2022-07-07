#!/bin/bash

dnf -y install git golang
git clone https://github.com/openshift/installer.git /var/tmp/openshift-installer
cd /var/tmp/openshift-installer
hack/build.sh
mkdir test-bare-metal
cp /vagrant/install-config.yaml test-bare-metal
bin/openshift-install create cluster
