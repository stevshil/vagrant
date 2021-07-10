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

ansible-playbook -i environments/dev nodes.yml

if hostname | grep master >/dev/null 2>&1
then
  ansible-playbook -i environments/dev master.yml
  if [[ -d /home/vagrant/kubespray/inventory/mycluster ]]
  then
    cd /home/vagrant/kubespray; ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root cluster.yml -e 'ansible_python_interpreter=/usr/bin/python3'

  else
    echo "Your cluster did not create"
  fi
fi
