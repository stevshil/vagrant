#!/bin/bash

# Required software

# Install GUI and apps and set auto logon
apt update
apt -y install tasksel
apt -y install ubuntu-mate-core
apt -y install mate-terminal firefox python3-pip python3-venv password-gorilla
ln -s /usr/bin/python3 /usr/bin/python
cp /vagrant/autologin.conf /etc/lighdm/lightdm.conf.d/autologin.conf
systemctl set-default graphical.target

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
mv kubectl /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
ln -s /usr/local/bin/kubectl /bin/kubectl

# Grab the kube config file of the server
cp /vagrant/kube_config/* .

# Restart to get GUI
init 6