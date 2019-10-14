#!/bin/bash

VBoxManage guestproperty get "Ansible Prov" "/VirtualBox/GuestInfo/Net/1/V4/IP"
