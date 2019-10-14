#!/bin/bash
# Don't run this as a script, but follow the lines step by step

# Set the hosts file;
cat >/etc/hosts <<_END_
127.0.0.1 localhost
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
192.168.18.100  rhel.al.local   puppet.al.local   puppet puppetdb
192.168.18.101  ubuntu.al.local
192.168.18.102  rhelpc.al.local
_END_

# Restart the puppetmaster
if rpm -qa | grep puppetserver >/dev/null 2>&1
then
	systemctl restart puppetserver
fi

# Install puppetdb
yum -y install http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm epel-release expect

yum -y install puppetdb puppetdb-termini puppetdb-terminus postgresql95 postgresql95-server postgresql95-contrib

/usr/pgsql-9.5/bin/postgresql95-setup initdb
systemctl start postgresql-9.5
systemctl enable postgresql-9.5

/vagrant/bin/createdb.sh

sed -i 's/peer$/md5/' /var/lib/pgsql/9.5/data/pg_hba.conf
sed -i 's/ident$/md5/' /var/lib/pgsql/9.5/data/pg_hba.conf

systemctl restart postgresql-9.5

/vagrant/bin/checkdb.sh

cat >/etc/puppetlabs/puppetdb/conf.d/database.ini <<_END_
[database]
classname = org.postgresql.Driver
subprotocol = postgresql
subname = //localhost:5432/puppetdb
username = puppetdb
password = secret
log-slow-statements = 10
_END_

echo "host = 0.0.0.0" >>/etc/puppetlabs/puppetdb/conf.d/jetty.ini

systemctl restart puppetdb
systemctl enable puppetdb

sleep 10

# At this stage you should do a netstat -tln, and check that port 8081 is there
if (( $(netstat -tln | grep 8081 | grep -v grep | wc -l) == 0 ))
then
	echo "Puppet DB did not start correctly, port 8081 not listening" 1>&2
	exit 1
fi

cat >/etc/puppetlabs/puppet/puppetdb.conf <<_END_
[main]
server_urls = https://rhel.al.local:8081
_END_

cat >>/etc/puppetlabs/puppet/puppet.conf <<_END_
storeconfigs=true
storeconfigs_backend=puppetdb
reports=puppetdb
_END_

cat >>/etc/puppetlabs/puppet/routes.yaml <<_END_
---
  master:
  facts:
    terminus: puppetdb
    cache: yaml
_END_

systemctl restart puppetserver

yum -y install python-pip git
pip install --upgrade pip
pip install --upgrade virtualenv
puppet module install nibalizer-puppetboard --environment=production
puppet module install puppetlabs-apache --environment=production

cat >/etc/puppetlabs/code/environments/production/manifests/site.pp <<_END_
node default {
	host {'rhel.al.local':
		ip => '192.168.18.100',
		host_aliases => ['puppet.al.local','puppet']
	}
	class { 'apache': }
	class { 'apache::mod::wsgi':
		wsgi_socket_prefix => '/var/run/wsgi' }
	class { 'puppetboard': }
	class { 'puppetboard::apache::vhost':
		vhost_name => 'rhel.al.local',
		port        => 80
	}
}
_END_

cat >/etc/puppetlabs/code/environments/production/hieradata/common.yaml <<_END_
puppetboard::git_source: https://github.com/voxpupuli/puppet-puppetboard.git
puppetboard::puppetdb_host: rhel.al.local
_END_

pip install puppetboard

puppet apply -t --modulepath=/etc/puppetlabs/code/environments/production/modules /etc/puppetlabs/code/environments/production/manifests/site.pp --environment=production

systemctl start httpd
systemctl enable httpd

# All existing clients will need to be rebuilt

# Required to enable agents to continue running, if certs are not working after
# a rebuild of client
#puppetdb ssl-setup -f
#systemctl puppetdb restart
