class installer (
	$localDir = hiera("installer::localDir","/LinuxImgs"),
	$aliasName = hiera("installer::aliasName","/Images"),
	$builds = hiera("installer::builds",undef),
	$liveos = hiera("installer::liveos","http://mirror.centos.org/centos/7/os/x86_64/LiveOS/squashfs.img"),
	$vmlinuz = hiera("installer::vmlinuz","http://mirror.centos.org/centos/7/os/x86_64/images/pxeboot/vmlinuz"),
	$initrd = hiera("installer::initrd","http://mirror.centos.org/centos/7/os/x86_64/images/pxeboot/initrd.img"),
	$repo = hiera("installer::repo","http://mirror.centos.org/centos/7/os/x86_64/")
) {
        service {'firewalld':
                ensure => running,
                enable => true,
        }

	host {'installer.training.local':
		ensure => present,
		host_aliases => 'installer',
		ip => $ipaddress,
	}

	package {['tftp-server','httpd','syslinux-tftpboot','dhcp']:
		ensure => latest,
	}

	service {'xinetd':
		ensure => running,
		enable => true,
		require => Package['tftp-server'],
	}

	exec {"/usr/bin/sed -i 's/disable.*$/disable = no/' /etc/xinetd.d/tftp":
		require => Package['tftp-server'],
		onlyif => "/usr/bin/grep 'disable.*yes' /etc/xinetd.d/tftp",
		notify => Service['xinetd'],
	}

	file { [ "$localDir","$localDir/centos7" ]:
		ensure => directory,
		mode => '755',
		owner => 'root',
		group => 'root',
	}

	file { '/etc/httpd/conf.d/mysites.conf':
		ensure => file,
		mode => '644',
		content => template('installer/mysites.erb'),
		notify => Service['httpd'],
		require => [Package['httpd'],File["$localDir"]],
	}

	service {'httpd':
		ensure => running,
		enable => true,
		require => Package['httpd'],
	}

	file { '/var/lib/tftpboot/pxelinux.cfg':
		ensure => directory,
		source => "puppet:///modules/installer/pxelinux.cfg",
		recurse => true,
		owner => root,
		group => root,
		require => Package['tftp-server'],
	}

	exec { 'get vmlinuz':
		command => "/usr/bin/curl $vmlinuz >/var/lib/tftpboot/vmlinuz",
		creates => "/var/lib/tftpboot/vmlinuz",
		require => Package['syslinux-tftpboot'],
	}

	exec { 'get initrd':
		command => "/usr/bin/curl $initrd >/var/lib/tftpboot/initrd.img",
		creates => "/var/lib/tftpboot/initrd.img",
		require => Package['syslinux-tftpboot'],
	}

	exec { 'get liveos':
		command => "/usr/bin/curl $liveos > $localDir/centos7/squashfs.img",
		creates => "$localDir/centos7/squashfs.img",
		require => File["$localDir/centos7"],
	}

	exec { 'Set selinux permission liveos':
		command => "/usr/bin/chcon -R --reference=/var/www $localDir",
		require => File["$localDir/centos7"],
		onlyif => "/usr/bin/ls -Z $localDir/centos7 | grep -v object_r:httpd_sys",
	}

	#file { '/var/lib/tftpboot/pxelinux.cfg/default':
		#ensure => file,
		#mode => 644,
		#content => template('installer/default.erb'),
		#require => File['/var/lib/tftpboot/pxelinux.cfg'],
	#}

	file { "$localDir/ks":
		ensure => directory,
		source => "puppet:///modules/installer/ks",
		owner => 'root',
		group => 'root',
		recurse => true,
		require => File["$localDir"],
	}

	file { "/etc/dhcp/dhcpd.conf":
		ensure => file,
		mode => 644,
		content => "authoritative;\nddns-update-style none;\n\nsubnet 192.168.1.0 netmask 255.255.255.0 {\n\trange 192.168.1.2 192.168.1.240;\n\toption subnet-mask 255.255.255.0;\n\toption routers 192.168.1.254;\n\toption domain-name-servers 8.8.8.8;\n\tallow unknown-clients;\n\n\tnext-server	192.168.1.254;\n\tfilename	\"pxelinux.0\";\n}\n",
		owner => 'root',
		group => 'root',
		require => Package['dhcp'],
		notify => Service['dhcpd'],
	}

	service { 'dhcpd':
		ensure => running,
		enable => true,
		require => Package['dhcp'],
	}

	exec { "Turn on forwarding":
		onlyif => "/usr/bin/grep -v ip_forward",
		command => "/usr/bin/echo 'net.ipv4.ip_forward = 1' >/etc/sysctl.conf; sysctl -p /etc/sysctl.conf",
	}

	exec { "Masquerade":
		onlyif => "/bin/firewall-cmd --zone=public --list-all | grep 'masquerade: no'",
		command => "/bin/firewall-cmd --permanent --zone=public --add-masquerade",
		notify => Service['firewalld']
	}

	exec { "Set up firewall":
		command => "/bin/firewall-cmd --permanent --zone=public --add-service=tftp; /bin/firewall-cmd --permanent --zone=public --add-service=http",
		onlyif => "/bin/firewall-cmd --list-services | /usr/bin/egrep -v 'tftp|http'",
		notify => Service['firewalld']
	}
}
