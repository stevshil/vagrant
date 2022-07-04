#!/bin/bash

wget https://github.com/rancher/rke/releases/download/v1.3.12/rke_linux-amd64 -O /usr/local/bin/rke
chmod +x /usr/local/bin/rke
ln -s /usr/local/bin/rke /bin/rke
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
mv kubectl /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
ln -s /usr/local/bin/kubectl /bin/kubectl

# Set up cluster
cp /vagrant/files/cluster.yml /home/vagrant/cluster.yml
sudo -u vagrant rke up --config cluster.yml