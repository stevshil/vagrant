#!/bin/bash

# Turn off firewall
systemctl disable --now firewalld

# Install software
yum -y install dhcp tftp-server vsftpd syslinux

# Configure DHCP
cat >> /etc/dhcp/dhcpd.conf << EOF
#DHCP configuration for PXE boot server
ddns-update-style interim;
ignore client-updates;
authoritative;
allow booting;
allow bootp;
allow unknown-clients;
subnet 192.168.10.0
netmask 255.255.255.0
{
  range 192.168.10.200 192.168.10.205;
  option domain-name-servers 192.168.10.210;
  option domain-name "okd.local";
  option routers 192.168.10.1;
  option broadcast-address 192.168.10.255;
  default-lease-time 600;
  max-lease-time 7200;
  #PXE boot server
  next-server 192.168.10.215;
  filename "pxelinux.0";
}

host okd4-bootstrap.lab.okd.local {
    hardware ethernet 08:00:27:81:45:E3;
    next-server 192.168.10.215;
    filename "pxelinux.0";
}

host okd4-control-plane-1.lab.okd.local {
    hardware ethernet 08:00:27:5E:E3:AB;
    next-server 192.168.10.215;
    filename "pxelinux.0";
}
EOF

systemctl enable --now dhcpd.service

# Start tftp
systemctl enable --now tftp.service
systemctl enable --now vsftpd.service

# Copy bootloaders
cp -v /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
cp -v /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
cp -v /usr/share/syslinux/mboot.c32 /var/lib/tftpboot/
cp -v /usr/share/syslinux/chain.c32 /var/lib/tftpboot/

mkdir /var/lib/tftpboot/pxelinux.cfg
# mkdir -p /var/lib/tftpboot/networkboot/coreos
# mkdir /var/ftp/pub/rhel7

# Download images
cd /var/lib/tftpboot
wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230303.3.0/x86_64/fedora-coreos-37.20230303.3.0-live-kernel-x86_64
wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230303.3.0/x86_64/fedora-coreos-37.20230303.3.0-live-initramfs.x86_64.img
wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230303.3.0/x86_64/fedora-coreos-37.20230303.3.0-live-rootfs.x86_64.img

cat >> /var/lib/tftpboot/pxelinux.cfg/default << EOF
default local
label local
    localboot 0
EOF

cat >> /var/lib/tftpboot/pxelinux.cfg/C0A80AC8 << EOF
default bootstrap
prompt 0
timeout 30
menu title Bootstrap Installer
label bootstrap
    KERNEL fedora-coreos-37.20230303.3.0-live-kernel-x86_64
    APPEND initrd=fedora-coreos-37.20230303.3.0-live-initramfs.x86_64.img,fedora-coreos-37.20230303.3.0-live-rootfs.x86_64.img ip=192.168.10.200::192.168.10.1:255.255.255.0:::none nameserver=192.168.10.210 coreos.inst.install_dev=/dev/sda coreos.inst.image_url=http://192.168.10.210:8080/okd4/fcos.raw.xz coreos.inst.ignition_url=http://192.168.10.210:8080/okd4/bootstrap.ign
IPAPPEND 2
EOF

cat >> /var/lib/tftpboot/pxelinux.cfg/C0A80AC9 << EOF
default controller
prompt 0
timeout 30
menu title Control Plane Installer
label controller
    KERNEL fedora-coreos-37.20230303.3.0-live-kernel-x86_64
    APPEND initrd=fedora-coreos-37.20230303.3.0-live-initramfs.x86_64.img,fedora-coreos-37.20230303.3.0-live-rootfs.x86_64.img ip=192.168.10.201::192.168.10.1:255.255.255.0:::none nameserver=192.168.10.210 coreos.inst.install_dev=/dev/sda coreos.inst.image_url=http://192.168.10.210:8080/okd4/fcos.raw.xz coreos.inst.ignition_url=http://192.168.10.210:8080/okd4/master.ign
IPAPPEND 2
EOF
