Package {
        allow_virtual => false
}

node /ldap.*/ {
	$env = 'vagrant'
	$fwstart=hiera('fwstart')
	$fwenabled=hiera('fwenabled')

        service {'iptables':
                ensure => $fwstart,
                enable => $fwenabled
        }

	class {'ipa':
		master  => true,
		domain  => 'training.local',
		realm   => 'TRAINING.LOCAL',
		adminpw => 'secret12',
		dspw    => 'secret12'
	}

	host {'ldap.training.local':
		ensure => present,
		host_aliases => 'ldap',
		ip => $ipaddress
	}
}
