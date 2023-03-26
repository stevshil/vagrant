# Using the assisted installer

This page outlines how to build a local SNO using the RHEL assisted installer.

# Installing an OpenShift Cluster manually

This document contains information on working out how to create a repeatable build of an OpenShift 4 cluster.

The issue is that Red Hat have made the process harder since version 4, requiring a Red Hat account first, and then not having a single node instance.

## Playgrounds on line

As a back up option, the following links provide online OpenShift

- https://developers.redhat.com/courses/explore-openshift/openshift-playground
  - Only 1 hour use
- https://developer.ibm.com/openlabs/openshift
  - Requires an IBM registration (sign up)
- https://github.com/okd-project/okd#getting-started
  - Using OKD4, not CRC
  - https://cloud.redhat.com/blog/okd4-is-now-generally-available


### Requirements

- Requires Red Hat account
- SSH key pair, public required for the ISO image to log on to the boot iso
- Min 19GB RAM
- Min 9 CPU cores
- 120GB or more of disk
- 120GB 2nd disk for LVM

Your own DNS server with the following entries:
```
api.lab.okd.local.    IN    A    192.168.10.175
api-int.lab.okd.local.    IN    A    192.168.10.175
apps.lab.okd.local.    IN    A    192.168.10.175
*.apps.lab.okd.local.    IN CNAME apps.lab.okd.local.
etcd-0.lab.okd.local.    IN    A     192.168.10.175
console-openshift-console.apps.lab.okd.local.     IN     A     192.168.10.175
oauth-openshift.apps.lab.okd.local.     IN     A     192.168.10.175
```

Reverse lookup:
```
175    IN    PTR    okd4-control-plane-1.lab.okd.local.
175    IN    PTR    okd4-compute-1.lab.okd.local.
175    IN    PTR    api.lab.okd.local.
175    IN    PTR    api-int.lab.okd.local.
175    IN    PTR    apps.lab.okd.local.
```

Changing the 192.168.10.175 and the 175 to your OpenShift server IP


1. https://console.redhat.com/openshift/assisted-installer
2. In Cluster Details
	- Cluster name: Name you wish to give to the cluster, this is the name that routes will be appended with as part of the DNS name
	- Base domain: Base domain that the host is in
	- OpenShift version 4+
	- Next
3. In Operators
	- Nothing needs to be ticked
4. Host Discovery
	- Click **Add Host** button
	- Provision type: Full Image File
	- SSH public key: Either copy and paste in the key, or click Browse tab to upload
	- Click **Generate Discovery ISO** to download the image
5. Use this ISO to boot the VM
	- This will then allow the VM to send information to the service
6. Storage
	- Leave as is it will detect the 120GB+ drive
	- You could select other disks
7. Network
	- Machine network needs to be set the network that your host is attached to
	- Tick the box for **Use advanced networking** and leave the defaults, this sets the cluster network
	- Keep the tick on **Use the same host discovery SSH key**
8. Click the **Install cluster** button
9. Let it run, the system will do the rest as it is waiting
10. Click the view host events to see what is happening, as well as the status

**NOTE** It can take around 50 minutes to complete the entire process.

You will use the ISO image to boot the VM, and you will need to ensure that it points to your DNS server to be able to complete the process.

During the installation the https://console.redhat.com/ will show a button for your KUBECONFIG configuration file to access using the **oc** command.  Download this file.

You will also get a box to view the **kubeadmin** password to log in to the console.  This will also be possible from the console.redhat.com **Open console** button in the cluster page.