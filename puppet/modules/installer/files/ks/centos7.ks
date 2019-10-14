text
install
url --url=http://mirror.centos.org/centos/7/os/x86_64/
reboot
rootpw --iscrypted $1$D2wLb9Xi$0BMSN7ENo9poluxh5n.0p.

auth  --useshadow  --enablemd5 
bootloader --location=mbr
zerombr
clearpart --all --initlabel 
firewall --disabled
firstboot --disabled
keyboard uk
lang en_GB
network --bootproto=dhcp --onboot=on

selinux --disabled
timezone  Europe/London
part swap --fstype="swap" --size=512
part / --fstype="ext3" --grow --size=1

%packages
@core
@development
%end
