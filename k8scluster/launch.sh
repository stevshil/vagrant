#!/bin/bash

# Script to create and Launch VMs for Rancher RKE Cluster, since
# Vagrantup can't do it without the NAT network.
. bin/config

# Environment variables to change
NIC=$(ip a | grep -B2 "$YOURSUBNET" | sed 's/^...//' | egrep '^(enp|eth|wlp)' | awk '{print $1}' | sed 's/://g')
echo $NIC

if [[ $# > 0 ]]
then
  hostlist="$@"
fi

# Get the Alma Linux 8 box
echo "Using $VBOX - $VBOXPATH"
if ! ls $VBOXPATH >/dev/null 2>&1
then
  if echo "$VBOX" | grep almalinux >/dev/null 2>&1
  then
    if ! vagrant box list | grep almalinux >/dev/null 2>&1
    then
      vagrant box add almalinux/8 --provider virtualbox
    fi
  else
    if ! vagrant box list groovy64 >/dev/null 2>&1
    then
      vagrant box add ubuntu/groovy64 --provider virtualbox
    fi
  fi
fi
# Grab the box name e.g. packer-almalinux-8-1622130088
#boxname=$(cat $VBOXPATH | grep vbox:Machine | head -1 | sed 's/^.*name="//' | sed 's/" OSType.*//')
boxname=$(grep VirtualSystemIdentifier $VBOXPATH | sed -e 's/^.*ier>\(.\)/\1/' -e 's,</.*$,,')

# Launch the Cluster VMs
for machine in $(echo $hostlist | sed 's/ proxy//')
do
  if ! VBoxManage list vms | grep "$machine"
  then
    if [[ $machine == "proxy" ]]
    then
	    RAM=1024
    fi
    echo "Importing image"
    VBoxManage import $VBOXPATH
    echo "Setting VM name"
    VBoxManage modifyvm $boxname --name $machine
    echo "Setting bridge NIC and memory"
    VBoxManage modifyvm $machine --ioapic on --memory $RAM --vram 16 --nic1 bridged --nictype1 $NICTYPE --cableconnected1 on --bridgeadapter1 $NIC
    echo "Adding Internal NIC"
    # Add internal nic
    VBoxManage modifyvm $machine --nic2 intnet --intnet1 "Internal Network"
    echo "Changing boot order"
    VBoxManage modifyvm  $machine --boot1 disk --boot2 dvd --boot3 none --boot4 none
  fi

  # Start VM
  echo "Starting VM *$machine*"
  if ! VBoxManage list runningvms | grep $machine >/dev/null 2>&1
  then
    VBoxManage startvm $machine --type headless
  fi

  echo "Waiting for IP for *$machine*"
  IP=$(VBoxManage guestproperty get $machine "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')
  while [[ ${IP} != ${YOURSUBNET}.* ]]
  do
    echo -n '.'
    sleep 5
    IP=$(VBoxManage guestproperty get $machine "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')
  done
  echo "VM IP = $IP"

  echo "Waiting for VM to ssh to $IP"
  while ! bash -c "</dev/tcp/$IP/22" 2>/dev/null
  do
    echo -n "."
    sleep 5
  done
  echo ""

  # Copy up files for install process
  echo "Copying install script"
  sshpass -p $VMPASS scp -r "$PWD" root@${IP}:
  echo "Set hostname"
  sshpass -p $VMPASS ssh root@$IP hostnamectl set-hostname $machine
  echo "Create python link to python3"
  sshpass -p $VMPASS ssh root@$IP ln -s /usr/bin/python3 /usr/bin/python
  echo "Removing current DNS resolver"
  sshpass -p $VMPASS ssh root@$IP rm -f /etc/resolv.conf
  echo "Adding new DNS resolver"
  if [[ -n $YOURDNS ]]
  then
    echo "Setting DNS resolver"
    sshpass -p $VMPASS ssh root@$IP "echo -e 'nameserver $YOURDNS\nsearch $YOURDOMAIN' >/etc/resolv.conf"
    sshpass -p $VMPASS ssh root@$IP "sed -i '/\[main\]/a\dns=none' /etc/NetworkManager/NetworkManager.conf"
  fi

  # Change VM IP
  case $machine in
    'k8snode1') newIP=${YOURSUBNET}.61
                intIP=10.0.0.61
                ;;
    'k8snode2') newIP=${YOURSUBNET}.62
                intIP=10.0.0.62
                ;;
    'k8smaster') newIP=${YOURSUBNET}.60
                 intIP=10.0.0.60
                ;;
    'proxy') newIP=${YOURSUBNET}.65
	           intIP=10.0.0.65
	     ;;
  esac

  echo "Changing VM IP from $IP to $newIP"
  sshpass -p $VMPASS ssh root@$IP "sed -i 's/BOOTPROTO=.*/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-enp0s3; echo -e 'IPADDR=${newIP}\nGATEWAY=${YOURGW}' >>/etc/sysconfig/network-scripts/ifcfg-enp0s3"
  # Internal NIC
  sshpass -p $VMPASS ssh root@$IP "echo -e 'TYPE=Ethernet\nBOOTPROTO=none\nNAME=enp0s8\nDEVICE=enp0s8\nONBOOT=yes\nIPADDR=$intIP' >/etc/sysconfig/network-scripts/ifcfg-enp0s8"
  echo "Rebooting VM"
  if [[ $newIP != $IP ]]
  then
    sshpass -p $VMPASS ssh root@$IP "init 6"
  fi

  if ! grep "^export $machine" tmpconfig
  then
    echo "export $machine=$newIP" >>tmpconfig
  fi

  echo "Waiting for VM to ssh to $newIP"
  while ! bash -c "</dev/tcp/$newIP/22" 2>/dev/null
  do
    echo -n "."
    sleep 5
  done
  echo ""

  echo "Running provision script"
  sshpass -p $VMPASS ssh root@$newIP "cd k8scluster; chmod +x bin/node.sh; bin/node.sh"
done

if echo "$hostlist" | grep proxy >/dev/null 2>&1
then
  vagrant up proxy
fi
