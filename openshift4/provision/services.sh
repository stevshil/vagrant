#!/bin/bash

echo "Set Public IP"
cat >/etc/systemd/network/10-eth1.network <<_EOD
[Match]
Name=eth1

[Network]
Address=192.168.10.210
Gateway=192.168.10.1
_EOD

systemctl daemon-reload
systemctl restart systemd-networkd

echo "Install all service packages"
dnf -y install wget git vim bind bind-utils haproxy httpd podman

echo "Disable Firewall"
systemctl disable --now firewalld

echo "Set selinux to permissive"
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/sysconfig/selinux

echo "Configure DNS"
cp -f /vagrant/named.conf /etc/named.conf
cp -f /vagrant/db.* /var/named
cp -f /vagrant/localhost.zone /var/named
systemctl enable --now named

echo "Tell NetworkManager to leave DNS alone"
if grep '^dns' /etc/NetworkManager/NetworkManager.conf >/dev/null 2>&1
then
    echo "NM OK"
else
    sed -i '/\[main\]/a\dns=none' /etc/NetworkManager/NetworkManager.conf
    systemctl restart NetworkManager
fi

echo "Set nsswitch file"
sed -i 's/hosts:.*files myhostname .*$/hosts:     files myhostname dns/' /etc/nsswitch.conf
echo -e "search okd.local\nnameserver 127.0.0.1" >/etc/resolv.conf

echo "Configure HAProxy"
cp -f /vagrant/haproxy.cfg /etc/haproxy/haproxy.cfg
setsebool -P haproxy_connect_any 1
systemctl enable --now haproxy

echo "Configure web service"
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
setsebool -P httpd_read_user_content 1
systemctl enable --now httpd

echo "Install openshift commands"
cd /tmp
RELEASE=4.12.0-0.okd-2023-03-18-084815
# RELEASE=4.5.0-0.okd-2020-07-29-070316  # Causes boot issues with CoreOS 37 which is the only release
# RELEASE=4.12.0-0.okd-2023-01-21-055900
wget https://github.com/okd-project/okd/releases/download/$RELEASE/openshift-client-linux-$RELEASE.tar.gz
wget https://github.com/okd-project/okd/releases/download/$RELEASE/openshift-install-linux-$RELEASE.tar.gz
tar xvf openshift-client-linux-$RELEASE.tar.gz
tar xvf openshift-install-linux-$RELEASE.tar.gz
mv kubectl oc openshift-install /usr/bin
rm *.tar.gz README.md
cd

echo "Generate SSH key"
[ -d $HOME/.ssh ] || mkdir $HOME/.ssh
cp /vagrant/keys/id_rsa* $HOME/.ssh
cp /vagrant/keys/id_rsa* /home/vagrant/.ssh
chown -R vagrant: /home/vagrant/.ssh
echo "Host *
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null" >$HOME/.ssh/config
cp $HOME/.ssh/config /home/vagrant/.ssh/config
chmod 600 $HOME/.ssh/config /home/vagrant/.ssh/config
chown vagrant: /home/vagrant/.ssh/config

echo "Creating the cluster config files"
mkdir -p /okdconfig/install_dir || exit 1
# cp /vagrant/install-config.yaml /okdconfig/install_dir/ || exit 2
# cp /vagrant/install-config.sno.yaml /okdconfig/install_dir/install-config.yaml || exit 2
PSECRET=$(cat /vagrant/private/pull-secret.txt)
# Choices for NETTYPE are OVNKubernetes|OpenShiftSDN
NETTYPE=OpenShiftSDN
sed -e "s/\$PULLSECRET/$PSECRET/" -e 's/$NETTYPE/OVNKubernetes/' /vagrant/install-config.sno.yaml.tmplt >/okdconfig/install_dir/install-config.yaml
openshift-install create manifests --dir=/okdconfig/install_dir/ || exit 3
openshift-install create ignition-configs --dir=/okdconfig/install_dir/ || exit 4
mkdir /var/www/html/okd4
cp -R /okdconfig/install_dir/* /var/www/html/okd4/ || exit 5
chown -R apache: /var/www/html/
chmod -R 755 /var/www/html/
curl localhost:8080/okd4/metadata.json

echo "Putting cluster config into web service"
cd /var/www/html/okd4
wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230303.3.0/x86_64/fedora-coreos-37.20230303.3.0-metal.x86_64.raw.xz
wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/37.20230303.3.0/x86_64/fedora-coreos-37.20230303.3.0-metal.x86_64.raw.xz.sig
curl -O https://getfedora.org/static/fedora.gpg
mv fedora-coreos-37.20230303.3.0-metal.x86_64.raw.xz fcos.raw.xz
mv fedora-coreos-37.20230303.3.0-metal.x86_64.raw.xz.sig fcos.raw.xz.sig
gpgv --keyring ./fedora.gpg fcos.raw.xz.sig fcos.raw.xz
chown -R apache: /var/www/html/
chmod -R 755 /var/www/html/

# Scripts for checking install
cat >/usr/local/bin/check-bootstrap <<_EOD
#!/bin/bash
cd /okdconfig
openshift-install wait-for bootstrap-complete --dir install_dir/ --log-level info
_EOD

chmod +x /usr/local/bin/check-bootstrap

cat >/usr/local/bin/check-install <<_EOD
#!/bin/bash
cd /okdconfig
openshift-install wait-for install-complete --dir install_dir/ --log-level info
_EOD

chmod +x /usr/local/bin/check-install
