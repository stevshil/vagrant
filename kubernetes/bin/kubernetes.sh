#!/bin/bash

# A combination of the 2 links;
## https://myopswork.com/how-to-install-kubernetes-k8-in-rhel-or-centos-in-just-7-steps-2b78331174a5
## https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
# Also
## https://medium.com/@lizrice/kubernetes-in-vagrant-with-kubeadm-21979ded6c63
## https://medium.com/@wso2tech/multi-node-kubernetes-cluster-with-vagrant-virtualbox-and-kubeadm-9d3eaac28b98

# Set hostname in /etc/hosts
MYIP=$(ifconfig | grep -A1 enp0s8 | tail -1 | awk '{print $2}')
if ! grep $MYIP /etc/hosts
then
  sed "s/^.*${HOSTNAME}.*$/${MYIP}  ${HOSTNAME}/" /etc/hosts
fi

cat <<EOF > /etc/yum.repos.d/centos.repo
[centos]
name=CentOS-7
baseurl=http://ftp.heanet.ie/pub/centos/7/os/x86_64/
enabled=1
gpgcheck=1
gpgkey=http://ftp.heanet.ie/pub/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7
#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=http://ftp.heanet.ie/pub/centos/7/extras/x86_64/
enabled=1
gpgcheck=0
EOF

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum -y install docker
systemctl enable docker
systemctl start docker
usermod -aG docker vagrant
usermod -aG root vagrant

# Make sure servers are listening on their real IP not the 10.0.2.15 VirtualBox address
# Only on RHEL/CentOS
if [[ -e /etc/redhat-release ]]
then
  if [[ ! -e /etc/default/kubelet ]]
  then
    touch /etc/default/kubelet
  fi
  sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$MYIP" /etc/default/kubelet
fi

yum -y install kubelet kubeadm kubectl
systemctl start kubelet
systemctl enable kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sysctl -w net.bridge.bridge-nf-call-iptables=1
swapoff -a
sed -i '/swap/d' /etc/fstab

export KUBERNETES_MASTER=http://$MYIP:8080
#sed -i '0,/ExecStart=/s//Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=cgroupfs"\n&/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# On the master only
if hostname | grep kubemaster >/dev/null 2>&1
then
  # For calico CNI to work --pod-network-cidr=192.168.0.0/16
  echo "kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=$MYIP --apiserver-cert-extra-sans=$MYIP --node-name $HOSTNAME" 1>&2
  kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=$MYIP --apiserver-cert-extra-sans=$MYIP --node-name $HOSTNAME | tee /vagrant/token

  # Check server configuration
  # kubectl -n kube-system get cm kubeadm-config -oyaml

  # Check cluster with
  # kubectl get nodes
  # Detailed node info
  # kubectl describe nodes
fi

if hostname | grep -v kubemaster >/dev/null 2>&1
then
  # On workers, all commands must run as root
  USEIP=$(ifconfig | grep -A1 enp0s8 | tail -1 | awk '{print $2}')
  cmd=$(grep 'kubeadm join' /vagrant/token | sed 's/10.0.2.15/192.168.205.10/')
  $cmd --apiserver-advertise-address=${USEIP}
fi
