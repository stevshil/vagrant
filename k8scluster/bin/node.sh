#!/bin/bash

# Install ansible and run playbooks
export DEBIAN_FRONTEND=noninteractive

if [[ -e /etc/lsb_release ]]
then
  apt-get -yq update
  apt-get -yq install ansible
else
  if which dnf >/dev/null 2>&1
  then
    dnf -y install epel-release
    dnf -y install ansible
  else
    yum -y install epel-release
    yum -y install ansible
  fi
fi
cd /vagrant
ansible-playbook -i /vagrant/environments/dev nodes.yml

if hostname | grep master >/dev/null 2>&1
then
  ansible-playbook -i /vagrant/environments/dev master.yml
  if [[ -d /home/vagrant/kubespray/inventory/mycluster ]]
  then
    cd /home/vagrant/kubespray; ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root cluster.yml
  else
    echo "Your cluster did not create"
  fi
fi
