#!/bin/bash

if [[ ! -e /vagrant/files/rke ]]
then
	wget https://github.com/rancher/rke/releases/download/v1.2.8/rke_linux-amd64 -O /vagrant/files/rke
fi

if [[ ! -e /usr/local/bin/rke ]]
then
	cp /vagrant/files/rke /usr/local/bin/rke
	chmod +x /usr/local/bin/rke
fi

if [[ ! -d /home/vagrant/.ssh ]]
then
	mkdir /home/vagrant/.ssh
	chown vagrant:vagrant /home/vagrant/.ssh
fi

if [[ ! -e /home/vagrant/.ssh/id_rsa ]]
then
	cp /vagrant/files/rke_rsa /home/vagrant/.ssh/id_rsa
	cat /vagrant/files/rke_rsa.pub >>/home/vagrant/.ssh/authorized_keys
	chown -R vagrant:vagrant /home/vagrant/.ssh
	chmod 600 /home/vagrant/.ssh/id_rsa*
fi

IP=$(ifconfig | grep -A1 enp0s8 | grep inet | awk '{print $2}')

cp /vagrant/files/fullcluster.yaml /home/vagrant/cluster.yml

# Install Docker
apt-get -y update
apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get -y update
apt-get -y install docker-ce docker-ce-cli containerd.io jq
usermod -G docker vagrant
# This would create you a new cluster.yml file
# rke config --name cluster.yml

pwd
# Deploy cluster
sudo -u vagrant rke up

# Install kubectl
if [[ ! -e /vagrant/files/kubectl ]]
then
	wget "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -O /vagrant/files/kubectl
fi

if [[ ! -e /usr/local/bin/kubectl ]]
then
	cp /vagrant/files/kubectl /usr/local/bin/kubectl
	chmod +x /usr/local/bin/kubectl
fi

# Add dasboard
sudo -u vagrant kubectl --kubeconfig kube_config_cluster.yml apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

# Create external access
cat >/home/vagrant/np.yml <<_END_
apiVersion: v1
kind: Service
metadata:
  name: externaldash
  namespace: kubernetes-dashboard
spec:
  type: NodePort
  selector:
    k8s-app: kubernetes-dashboard
  ports:
    - port: 8443
      targetPort: 8443
      nodePort: 30007
_END_
sudo -u vagrant kubectl --kubeconfig kube_config_cluster.yml apply -f /home/vagrant/np.yml

# Create dashboard user
cat >/home/vagrant/user.yml <<_END_
apiVersion: v1
kind: ServiceAccount
metadata:
  name: support
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: support
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: support
  namespace: kubernetes-dashboard
_END_
sudo -u vagrant kubectl --kubeconfig kube_config_cluster.yml apply -f /home/vagrant/user.yml

# Token to use to login to dashboard
sudo -u vagrant kubectl --kubeconfig kube_config_cluster.yml -n kubernetes-dashboard get secret $(kubectl --kubeconfig kube_config_cluster.yml -n kubernetes-dashboard get sa/support -o jsonpath="{.secrets[0].name}")"

sudo -u vagrant mkdir /home/vagrant/bin
echo "kubectl --kubeconfig kube_config_cluster.yml -n kubernetes-dashboard get secret $(kubectl --kubeconfig kube_config_cluster.yml -n kubernetes-dashboard get sa/support -o jsonpath=\"{.secrets[0].name}\") -o go-template=\"{{.data.token | base64decode}}\"" >/home/vagrant/bin/getlogin
chown vagrant:vagrant /home/vagrant/bin/getlogin
chmod +x /home/vagrant/bin/getlogin
