Package {
	allow_virtual => false
}

node /installer.*/ {
	$env = 'vagrant'

	include installer
}
