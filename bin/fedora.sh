#!/bin/bash

dnf -y update
dnf -y groupinstall "Hawaii Desktop"
dnf -y install gdm
systemctl enable gdm.service
systemctl set-default grahical.target
