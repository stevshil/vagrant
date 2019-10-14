#!/bin/bash -eux

yum -y update
#useradd -m ec2-user
#(sleep 2; echo "ALsecret1234"; sleep 2; echo "ALsecret1234" | passwd ec2-user

yum install -y cloud-init cloud-utils-growpart dracut-modules-growroot

cat >/etc/cloud/cloud.cfg <<-'EOF'
users:
 - default

disable_root: 1
ssh_pwauth:   0
locale_configfile: /etc/sysconfig/i18n
mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']
resize_rootfs_tmp: /dev
ssh_deletekeys:   0
ssh_genkeytypes:  ~
syslog_fix_perms: ~

cloud_init_modules:
 - bootcmd
 - write-files
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - rsyslog
 - users-groups
 - ssh

cloud_config_modules:
 - mounts
 - locale
 - set-passwords
 - timezone
 - runcmd

cloud_final_modules:
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - final-message

system_info:
  default_user:
    name: ec2-user
    lock_passwd: true
    gecos: Cloud User
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: rhel
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: sshd

# vim:syntax=yaml
EOF

rm -rf /root/.ssh
userdel -r vagrant
