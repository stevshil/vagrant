# RKE Rancher Cluster

This vagrant configuration builds a K8s Cluster of 3 nodes;
* Master
* Worker x 2

The cluster also has an NGINX ingress service running on port 80 (no SSL certs created so no SSL).

An HAProxy external load balancer is also added to allow the use of the k8s.tps.local domain to be used to access applications running on your K8s cluster and that have an Ingress added to their services.

You'll notice that the haproxy.cfg file is configured to check the simple application to see which node is alive.  Since NGINX is using NodePort to expose the applications you will need to set your HAProxy to target the relevant app, since it will need to know which node the application is running on.  You'll also notice in the haproxy.cfg file that the DNS name of rd.k8s.tps.local is used in the check.

# Setting up

Since Rancher works better with a single NIC per machine, we need to remove the Vagrant NAT NIC during the installation and before running the **rke up** command.  The installation is therefore a 2 part install.

## Part 1

All nodes are installed with the **node.sh** script running.  This will install the core software and disable the NAT NIC.  You will then need to log on with regular SSH to the IP addresses end 60, 61 and 62, having changed the **YOURSUBNET** variable at the top of the **Vagrantfile**.  Also not forgetting to specify which NICs are likely to be used on your system in the **NICS** array.  The **NICS** array should be those that will be available on your system and it will use the first available.

The systems will reboot after completing the **node.sh** provisioning script. You will be able to log on using;

```
ssh vagrant@YOURSUBNET.61
```

Where YOURSUBNET is the subnet value of your network.  The 61 should be replaced by;
* 60 - Master
* 61 - Node1
* 62 - Node2

The password for vagrant and root is **vagrant**

## Part 2

Log on to the Master (YOURSUBNET.60) and complete the installation by running the following commands;

```
cd /vagrant
sudo bin/rke-master.sh
```

## Testing node/pod routing

Once complete the system should be ready.  You can test internode/pod connectivity by using the **testscripts** directory.

See [test script documentation](testscripts/README.md)

## Simple APP

A simple application can be deployed by deploying the files in the **files/simpleapp** directory.
