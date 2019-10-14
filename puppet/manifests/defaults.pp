Package {
        allow_virtual => false
}

node default {
	$env = 'vagrant'
	$fwstart=hiera('fwstart')
	$fwenabled=hiera('fwenabled')

	include myhosts

	service {'iptables':
		ensure => $fwstart,
		enable => $fwenabled
	}

	service {'cupsd':
		ensure => stopped,
		enable => false
	}

	user {'mypuppet':
		ensure => present,
		comment => 'Puppet created user',
		home => '/home/mypuppet'
	}

	package {'wget':
		ensure => latest
	}
}
