# Jenkins Local VM

This project builds a local VM using Vagrant and VirtulBox on you local machine.

## Mac

If you have a Mac then you can install Vagrant and VirtualBox using Brew;

``` brew cask install virtualbox ```

``` brew cask install vagrant ```

## Linux and Windows

Download the relevant packages from Oracle VirtualBox and Hashicorp Vagrantup

# Running

If you make changes to the *Vagrantfile* you should use the ``` ./validate ``` script to ensure that you haven't broken the build, before releasing your code.

## VM control

### Start VM

``` vagrant up jenkins ```

This will create the VM and provision it, if it does not exist, or start it if it has already been created.

### Stop the VM

``` vagrant halt jenkins ```

Shuts the VM down safely without having to log on and do ``` sudo init 0 ```

### Provision a failed VM

If your VM started to build, but failed during the provision, you can make changes to your scripts and then provision with;

``` vagrant provision jenkins ```

### Deleting the VM

``` vagrant destroy jenkins ```
