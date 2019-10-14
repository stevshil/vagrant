# vagrant
Vagrant build images

This project has been created for some basic Vagrant configurations to help with building training classes.  You should create a base box in Vagrant of CentOS and this project will do the rest.

Vagrant images should use the PD ssh key or the vagrant password


The bin directory is for Linux shell script provisioning
The puppet directory is for Puppet configuration manifests for use with puppet apply

After a VM has been updated you will need to re-sync VBoxAdditions, use the following command;
	vagrant plugin install vagrant-vbguest
