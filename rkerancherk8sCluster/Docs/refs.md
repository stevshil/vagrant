# References

NGINX Ingress LB - https://rancher.com/docs/rancher/v1.6/en/kubernetes/ingress/

Adding Ingress to your app with the inbuilt Rancher NGINX ingress - https://rancher.com/blog/2018/2018-09-26-setup-basic-kubernetes-cluster-with-ease-using-rke/

Ranchers ingress controller config https://rancher.com/docs/rke/latest/en/config-options/add-ons/ingress-controllers/

Using nginx ingress controller - https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-ingress-guide-nginx-example.html

## Rancher config

### NGINX Ingress
* https://rancher.com/docs/rancher/v2.x/en/k8s-in-rancher/load-balancers-and-ingress/ingress/
* https://rancher.com/docs/rke/latest/en/config-options/add-ons/ingress-controllers/
* https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/

### DNS
* https://rancher.com/docs/rke/latest/en/config-options/add-ons/dns/

### Authorization
* https://rancher.com/docs/rke/latest/en/config-options/authorization/

### Add-ons
* https://rancher.com/docs/rke/latest/en/config-options/add-ons/

### Authentication
* https://rancher.com/docs/rke/latest/en/config-options/authentication/

### Network
* https://rancher.com/docs/rke/latest/en/config-options/add-ons/network-plugins/

### Services
* https://rancher.com/docs/rke/latest/en/config-options/services/

### Nodes
* https://rancher.com/docs/rke/latest/en/config-options/nodes

# Networking not working

If you are seeing errors in your pods as;

```
Events:
  Type     Reason                  Age                 From               Message
  ----     ------                  ----                ----               -------
  Normal   Scheduled               34m                 default-scheduler  Successfully assigned ingress-nginx/default-http-backend-6977475d9b-whm88 to 10.0.0.11
  Warning  NetworkNotReady         33m (x25 over 34m)  kubelet            network is not ready: runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
  Warning  FailedCreatePodSandBox  29m (x41 over 32m)  kubelet            (combined from similar events): Failed to create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "8800ac6d696e413aabd235ee063ca68181173c3d2608e28d605ab6ed3a0f0070" network for pod "default-http-backend-6977475d9b-whm88": networkPlugin cni failed to set up pod "default-http-backend-6977475d9b-whm88_ingress-nginx" network: stat /var/lib/calico/nodename: no such file or directory: check that the calico/node container is running and has mounted /var/lib/calico/
```

Then https://github.com/rancher/rancher/issues/13484 helps. You need to;

1. On all nodes create the empty file /etc/cni/net.d/10-flannel.conflist
2. Restart the cluster

Check the pods again to ensure that the messages have stopped.  If not;

Run the following command;

```
kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml
```

And if that's still not working;

To anyone out there running rancher 2.4.8 on CentOS 7 in combination with calico.
I had to create a /etc/resolv-kubernetes/resolv.conf with my nameservers in it.

# Getting INGRESS working
https://forums.rancher.com/t/getting-ingress-to-work-with-default-rancher-2-x-setup/12109

# Check ingress port
kubectl describe endpoints default-http-backend -n ingress-nginx

Also check if port 80 is open (should only be on worker nodes)


# Installing a cluster using Rancher UI
* https://rancher.com/docs/rancher/v2.x/en/quick-start-guide/deployment/quickstart-manual-setup/

# Adding HAProxy ingress so you can target master
```
kubectl apply -f https://raw.githubusercontent.com/haproxytech/kubernetes-ingress/v1.4.0/deploy/haproxy-ingress.yaml
```

## Get the port 80 address
```
kubectl get svc --namespace=haproxy-controller | grep haproxy-ingress | awk '{print $5}' | awk -F, '{print $1}' | sed -e 's/^.*://' -e 's,/.*$,,'
```

# HAProxy checks

https://www.haproxy.com/documentation/aloha/latest/traffic-management/lb-layer7/health-checks/

# Checking RKE Rancher Networking
https://rancher.com/docs/rancher/v2.x/en/troubleshooting/networking/

Useful for when pods cannot communicate between nodes
Use - kubectl rollout status ds/overlaytest -w
Then run the shell script

# Inter pod routing fails

https://goteleport.com/blog/troubleshooting-kubernetes-networking/
