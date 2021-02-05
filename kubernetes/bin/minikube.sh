#!/bin/bash

# Install Docker requirement
yum -y install docker || (echo "Failed to install Docker" && exit 1)

# Enable and start docker
systemctl enable docker
systemctl start docker

# Turn off swap and permanently
swapoff -a
sed -i '/swap/d' /etc/fstab

# Set bridge-nf-call-iptables to 1
sysctl -w net.bridge.bridge-nf-call-iptables=1

# Install software requirements
yum -y install conntrack-tools

# Download minikube and install
if [[ ! -f /usr/local/bin/minikube ]]
then
  if curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  then
    chmod +x minikube
    mv minikube /usr/local/bin
  fi
fi

# Start Kubernetes
if [[ -f /usr/local/bin/minikube ]]
then
  /usr/local/bin/minikube --vm-driver=none start
  #/usr/local/bin/minikube --vm-driver=virtualbox start
  #/usr/local/bin/minikube config set vm-driver virtualbox
fi

ln -s /var/lib/minikube/binaries/v*/kubectl /bin/kubectl
