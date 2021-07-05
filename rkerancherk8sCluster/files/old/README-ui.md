# RKE Rancher Cluster

This vagrant configuration builds a K8s Cluster of 3 nodes;
* Master
* Worker x 2

The cluster also has an NGINX ingress service running on port 80 (no SSL certs created so no SSL).

An HAProxy external load balancer is also added to allow the use of the k8s.tps.local domain to be used to access applications running on your K8s cluster and that have an Ingress added to their services.

You'll notice that the haproxy.cfg file is configured to check the simple application to see which node is alive.  Since NGINX is using NodePort to expose the applications you will need to set your HAProxy to target the relevant app, since it will need to know which node the application is running on.  You'll also notice in the haproxy.cfg file that the DNS name of rd.k8s.tps.local is used in the check.

# Rancher UI using Docker rancher/rancher

Install 4 systems, with the rancher ui being on a 2GB VM.
3 systems will be configured as;
* 1 x Master
* 2 x Worker

Once the UI is up you can create a new cluster and to do that simply do;
* Click **Add Cluster** from the Global view
* Click **Existing Nodes**
* Type in a cluster name
* Click **Next**

On this page you will do the following;
* Select all 3 options, control-plane, etcd, worker
* Copy and paste the docker command into your Master nodes command line
  - Click the **Show advanced options** and add the IP address of your servers, if you're using Vagrant so that it uses the 10.0.0 addresses
* Select etcd and worker, and copy and paste the command into the worker nodes
  - Click the **Show advanced options** and do the same as before
* Do the same for each worker
* Then click done once you see the message about number of nodes registered

## Master command

```
sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run  rancher/rancher-agent:v2.5.9-rc4 --server https://192.168.10.63 --token qqrhm6ncvpw2xvm4ptrjcssg84kwf5djc9s9vdvpjgtn874f5jp74v --ca-checksum 0a4edf4f11e899317435541c8ef1bd979205a77a11b6318ed37778afeb0dc587 --node-name master --address 10.0.0.10 --etcd --controlplane --worker
```

## Worker command

```
sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run  rancher/rancher-agent:v2.5.9-rc4 --server https://192.168.10.63 --token qqrhm6ncvpw2xvm4ptrjcssg84kwf5djc9s9vdvpjgtn874f5jp74v --ca-checksum 0a4edf4f11e899317435541c8ef1bd979205a77a11b6318ed37778afeb0dc587 --node-name master --address 10.0.0.11 --etcd --worker  
```
