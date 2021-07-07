#!/bin/bash

# Script to create and Launch VMs for Rancher RKE Cluster, since
# Vagrantup can't do it without the NAT network.

# Environment variables to change
ISO="/home/steve/Downloads/AlmaLinux-8.4/AlmaLinux-8.4-x86_64-minimal.iso"
NIC=$(ip a | grep -B2 192 | sed 's/^...//' | egrep '^(enp|eth)' | awk '{print $1}' | sed 's/://g')

if [[ $# > 0 ]]
then
  hostlist="$@"
else
  hostlist="rkenode1 rkenode2 rkemaster proxy"
fi

. src/config

# Create the hosts file based on config
sed -e "s/YOURSUBNET/$YOURSUBNET/g" -e "s/YOURDOMAIN/$YOURDOMAIN/g" src/etc_hosts.tmplt >etc_hosts

# Get the Alma Linux 8 box
if [[ ! -e ~/.vagrant.d/boxes/almalinux*8/*/virtualbox/box.ovf ]]
then
  vagrant box add almalinux/8 --provider virtualbox
fi
# Grab the box name e.g. packer-almalinux-8-1622130088
boxname=$(cat ~/.vagrant.d/boxes/almalinux*8/*/virtualbox/box.ovf | grep vbox:Machine | head -1 | sed 's/^.*name="//' | sed 's/" OSType.*//')
# Launch the Cluster VMs
for machine in $(echo $hostlist | sed 's/ proxy//')
do
  if ! VBoxManage list vms | grep "$machine"
  then
    VBoxManage import ~/.vagrant.d/boxes/almalinux*8/*/virtualbox/box.ovf
    VBoxManage modifyvm $boxname --name $machine
    VBoxManage modifyvm $machine --ioapic on --memory $RAM --vram 16 --nic1 bridged --nictype1 $NICTYPE --cableconnected1 on --bridgeadapter1 $NIC --audio none
    echo "Adding CDROM"
    VBoxManage storageattach $machine --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "$ISO"
    echo "Changing boot order"
    VBoxManage modifyvm  $machine --boot1 disk --boot2 dvd --boot3 none --boot4 none
  fi

  # Start VM
  echo "Starting VM"
  if ! VBoxManage list runningvms | grep $machine >/dev/null 2>&1
  then
    VBoxManage startvm $machine --type headless
    echo "Waiting for IP"
  fi

  IP=$(VBoxManage guestproperty get $machine "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')
  while [[ ${IP} != ${YOURSUBNET}.* ]]
  do
    echo -n '.'
    sleep 5
    IP=$(VBoxManage guestproperty get $machine "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')
  done
  echo "VM IP = $IP"

  echo "Waiting for VM to ssh to $IP"
  while ! bash -c "</dev/tcp/$IP/22"
  do
    echo -n "."
    sleep 5
  done
  echo ""

  # Copy up files for install process
  echo "Copying config"
  sshpass -p $VMPASS scp src/config root@${IP}:
  echo "Copying install script"
  sshpass -p $VMPASS scp src/node.sh root@${IP}:
  echo "Copying ssh keys"
  sshpass -p $VMPASS scp src/rke_rsa* root@${IP}:/var/tmp
  echo "Removing current DNS resolver"
  sshpass -p $VMPASS ssh root@$IP rm -f /etc/resolv.conf
  echo "Adding new DNS resolver"
  if [[ -n $YOURDNS ]]
  then
    echo "Setting DNS resolver"
    sshpass -p $VMPASS ssh root@$IP "echo -e 'nameserver $YOURDNS\nsearch $YOURDOMAIN' >/etc/resolv.conf"
    sshpass -p $VMPASS ssh root@$IP "sed -i '/\[main\]/a\dns=none' /etc/NetworkManager/NetworkManager.conf"
  fi

  echo "Copying hosts file"
  sshpass -p $VMPASS scp etc_hosts root@$IP:/etc/hosts

  echo "Running common script"
  sshpass -p $VMPASS ssh root@$IP "chmod +x node.sh; ./node.sh"

  # Change VM IP
  case $machine in
    'rkenode1') newIP=${YOURSUBNET}.61
                ;;
    'rkenode2') newIP=${YOURSUBNET}.62
                ;;
    'rkemaster') newIP=${YOURSUBNET}.60
                ;;
    esac
  echo "Changing VM IP from $IP to $newIP"
  sshpass -p $VMPASS ssh root@$IP "sed -i 's/BOOTPROTO=.*/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-enp0s3; echo -e 'IPADDR=${newIP}\nGATEWAY=${YOURGW}' >>/etc/sysconfig/network-scripts/ifcfg-enp0s3"

  echo "Rebooting VM"
  sshpass -p $VMPASS ssh root@$IP "init 6"

  if ! grep "^export $machine" tmpconfig
  then
    echo "export $machine=$newIP" >>tmpconfig
  fi

  if [[ $machine == "rkemaster" ]]
  then
    IP=$newIP
    echo "Waiting for VM to ssh to $IP"
    while ! bash -c "</dev/tcp/$IP/22"
    do
      echo -n "."
      sleep 5
    done
    echo ""

    # Get kubectl and RKE binaries if not already local
    echo "Check if we already have rke"
    if [[ ! -e files/rke ]]
    then
      echo "Downloading rke binary"
      wget https://github.com/rancher/rke/releases/download/v1.2.8/rke_linux-amd64 -O files/rke
    fi
    echo "Check if we already have kubectl"
    if [[ ! -e files/kubectl ]]
    then
      echo "Downloading kubectl binary"
      wget "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -O files/kubectl
    fi

    echo "Copying master script"
    sshpass -p $VMPASS scp src/master.sh src/fullcluster.yml src/lbstatus.yml root@${IP}:
    echo "Copying rke and kubectl binary"
    sshpass -p $VMPASS scp files/rke files/kubectl root@${IP}:/var/tmp
    echo "Running master script"
    sshpass -p $VMPASS ssh root@${IP} "mv fullcluster.yml cluster.yml; chmod +x master.sh; ./master.sh"
  fi
done

if echo "$hostlist" | grep proxy >/dev/null 2>&1
then
  vagrant up proxy
fi
