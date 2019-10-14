#!/bin/bash

if (( $# < 1 ))
then
	echo "Please provide VM name"
fi

vboxmanage setextradata "$1" "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" "1"
