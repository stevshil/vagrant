#!/bin/bash

# Script to insert the guest additions ISO from CLI

if [ ! -e /mnt/VBoxLinuxAdditions.run ]
then
	vagrant ssh $1 -- sudo mount /dev/cdrom /mnt 
fi
vagrant ssh $1 -- sudo /mnt/VBoxLinuxAdditions.run
vagrant ssh $1 -- sudo umount /mnt 
vagrant ssh $1 -- sudo init 6
