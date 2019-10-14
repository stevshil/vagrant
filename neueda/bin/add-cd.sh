#!/bin/bash

# Script to insert the guest additions ISO from CLI

#VBoxManage storageattach "$1" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium "/usr/share/virtualbox/VBoxGuestAdditions.iso"
VBoxManage storageattach "$1" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium additions
