# NOTE: This is now superceded by [kubernetes-rke](../kubernetes-rke/)

This folder will soon be removed and will link to the newer version of this cluster build at [kubernetes-rke](../kubernetes-rke/)


# RKE Rancher Cluster

This configuration builds a K8s Cluster of 3 nodes;
* Master
  - Main server that controls the cluster
  - Also runs a worker node
  - IP Address: ${YOURSUBNET}.60
* Worker x 2
  - IP Address: ${YOURSUBNET}.61 and .62
  - Nodes that will run containers
* Proxy/Load Balancer for external application access
  - HAProxy based on identifying how to access the Ingress service
  - IP Address: ${YOURSUBNET}.65

The cluster also has an NGINX ingress service running on port 80 (no SSL certs created so no SSL).

An HAProxy external load balancer is also added to allow the use of the k8s.tps.local domain (change in the **src/config** file **YOURDOMAIN** variable, and the **YOURDNS** to set your DNS server IP) to be used to access applications running on your K8s cluster and that have an Ingress added to their services.

You'll notice that the [files/proxy/haproxy.cfg](files/proxy/haproxy.cfg) file is configured to check the simple lbcheck (src/lbstatus.yml) application to see which node is alive.  Since NGINX is using NodePort to expose the applications you will need to set your HAProxy to target the relevant app, since it will need to know which node the application is running on.  You'll also notice in the haproxy.cfg file that the DNS name of rd.k8s.tps.local is used in the check.

# Setting up

Since Rancher works better with a single NIC per machine, I have modified the installation so that it still uses Vagrant images, but instead of using **vagrant up** which generates it's own NAT NIC and confuses Rancher, I have created the following scripts;

* launch.sh
  - This script creates and provisions the environment
  - You can also specify which VMs to build by adding arguments
* vmstatus
  - This will tell you the state of the VMs
* haltvms
  - This allows you to stop all the VMs leaving them configured
* startvms
  - Starts all the VMs
* remove
  - Destroys the whole environment
* connect
  - Allows you to select which server to ssh on to
  - The information comes from a runtime file called **tmpconfig** - do not delete this file, it is removed when you run the **remove** script.

## External Proxy/LB

Once the environment is up and running haproxy ${YOURSUBNET}.65 will have the status page available as follows;

```
http://${YOURSUBNET}.65:9999/stats
```

# Connecting to the cluster

You can use the **connect** script to select the system to ssh on to.  The **rkemaster** has **kubectl** installed, but you would need to scp files to it to be able to run them.  The username is either **root** or **vagrant** and the password also **vagrant* for both users if you want to manually run ssh/scp commands.

If you want to use **kubectl** from your own system, then you will need to copy the **kube_config_cluster.yml** file from the **rkemaster** on to your local machine.  You can then do either;

* Use an environment variable
  ```
  export KUBECONFIG=kube_config_cluster.yml
  ```
* Use the --kubeconfig option to the kubectl command
  ```
  kubectl --kubeconfig kube_config_cluster.yml ......
  ```
* Create a kube config file
  ```
  mkdir ~/.kube
  mv kube_config_cluster.yml .kube/config
  ```

# Testing

To test the cluster we have provided a routing testing configuration and scripts as well as a simple application with an external Ingress that is based on the DNS name of **rd.k8s.tps.local**, so you will need to change the ingress.yml file to your domain name.

Depending whether you have copied down the kube_config_cluster.yml to your local machine, or whether you're using the master to run everything will depend on how you install the tests below.

If you are logging on to the rkemaster then you'll need to scp the files/directories onto the server first to be able to run them.  If running local then you can simply change to the files folder and the application you wish to run and use the kubectl command if you've installed it locally too.

## Testing node/pod routing

Once complete the system should be ready.  You can test internode/pod connectivity by using the **testscripts** directory.

See [test script documentation](files/testscripts/README.md)

## Simple APP

A simple application can be deployed by deploying the files in the **files/simpleapp** directory.

To make this work for your DNS you will need to edit the [ingress.yml file](files/simpleapp/ingress.yml) and change;

```
- host: rd.k8s.tps.local
```
