class myhosts (
	$thosts = hiera_hash('myhosts::hosts')
) {
	notify{'CheckingResource':
		message => "hosts are $thosts"
	}
	create_resources( 'host', $thosts )
}
