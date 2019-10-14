Package {
        allow_virtual => false
}

node /gitlab.*/ {
        $env = 'vagrant'

	service {'firewalld':
		ensure => stopped,
		enable => false,
	}

	include gitlab

	host {'gitlab':
		ensure => present,
		host_aliases => 'gitlab.training.local',
		ip => $ipaddress
	}

	exec {'/usr/sbin/setenforce 0': }
}
