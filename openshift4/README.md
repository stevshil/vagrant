# On Premise Single Node

This page defines the set up to install a Single Node Cluster (SNC) on site using OKD.

## Before starting requirements

1. VirtualBox or physical servers, a minimum of 3
2. Vagrant, if you want to build the Services server automatically
    - Manual build requires you to crate
        - DNS service with the values from db.okd.local and db.192.168.10 added to your DNS
        - HAProxy with the haproxy.cfg configuration applied
        - HTTP server with the ignition files added (these are created through the services.sh script)
        - PXE server this has the boot images and IPs for the servers you're building.

## Requirements

This set up uses 3 hosts;
- 1. A Services machine
    - okd4-services.okd.local.
    - 192.168.10.210
    - Provides the following services
      - DNS, HAProxy, HTTP on port 8080, PXE
    - This server will be required after the install to ensure OpenShift URLs work.
    - Hardware
        - RAM: 4GB
        - DISK: 40GB
        - CPUs: 2
2. A Bootstrap node
    - okd4-bootstrap.lab.okd.local.
    - 192.168.10.200
    - Hardware
        - RAM: 4GB
        - DISK: 120GB
        - CPUs: 2
3. A control-plane
    - okd4-control-plane-1.lab.okd.local.
    - 192.168.10.201
    - Hardware
        - RAM: 18GB
        - DISK: 120GB
        - DISK2: 120GB
        - CPUs: 8
    - This host will be the final OpenShift 4 server

**NOTE:** Hardware requirements are absolute minimum

If you change the IP addresses make sure you change the following files;
- named.conf
- haproxy.cfg
- db.okd.local
- db.192.168.10
- pxe.sh
- services.sh


## Starting the build

1. First you need to launch the services system.  You can do this by running the below command in the root of this project, where you see the **Vagrantfile**.
    ```
    vagrant up
    ```
2. Open a web browser and point it at the HAProxy stats page;
    - https://192.168.10.210:9000
    - During the install the bootstrap node will go from green back to red as the control-plane takes over.  Don't panic.
3. Once the server has built you can then start the **bootstrap** server and PXE boot it.
    - The server will reboot a couple of times
    - After the 2nd reboot you can log on to the server
        ```
        ssh core@192.168.10.200
        sudo journalctl -xfe
        ```
        **NOTE:** this is done from the **Services** host
    - See **Hints** for more info, and when to start the next server
    - Once the cluster is fully up and running you can down the **bootstrap** server.
4. Start the **Control Plane** to PXE boot
    - The server will reboot a couple of times
    - After the 2nd reboot you can log on to the server
        ```
        ssh core@192.168.10.201
        sudo journalctl -xfe
        ```
        **NOTE:** this is done from the **Services** host
    - See **Hints** for more info, and when to start the next server
5. At this point on the **Services** machine run the monitoring script
    ```
    sudo check-install
    ```

The installation will take around 50 minutes to complete from starting the Control Plane, depending on resources/hardware.

Keep an eye on the check-install script output, journalctl and HAProxy stats page.  See the **Hints** section for getting an idea of what to look for once it has started.  You should also be able to point your web browser at the web console too, and accept the self-signed certs to the log in screen.

## Checking the build

Try pointing your web browser at https://console-openshift-console.apps.lab.okd.local

You should get the accept the self-signed certificate.  Accept the risk.

You'll then need to accept the self-signed certificate for https://oauth-openshift.apps.lab.okd.local.

Once done you'll get the OpenShift 4 web console login.

User name is:  **kubeadmin**
Password will be found on the **Services** server in **/okdconfig/install_dir/auth/kubeadmin-password**

To use the **oc** command on the services machine you'll need to;
```
export KUBECONFIG=/okdconfig/install_dir/auth/kubeconfig
```

## Creating a quick app to check routing

1. Log in to the web console
    - https://console-openshift-console.apps.lab.okd.local
    - Username: kubeadmin
    - Password: Found on the **Services** node in /okdconfig/install_dir/auth/kubeadmin-password
2. Click on the **burger** menu button top left of the screen
3. Select **Home** then **Projects**
4. Click the **Create Project** button
5. Type in **demo** into the **Name** box and click the **Create** button
6. Click the **burger** menu button again
7. Select **Deployments**
8. Click **Create Deployment** button
9. In the **Name** type **hello**
10. Scroll down to **Image Name** and remove the text in that box and replace with **docker.io/openshift/hello-openshift**
11. Click **Create** button
12. 3 pods should launch and the circle should go dark blue
13. Click the **burger** menu button again
14. Select **Networking** then **Services**
15. Click the **Create Service** button
16. Change the **app: MyApp** to **app: hello**, and the **name: example** to **name: demo**
17. Change the **targetPort** value from **9376** to **8080** which is the port our hello-openshift container is listening on
18. Click the **Create** button
19. Click the **burger** menu button again
20. Select **Routes** under **Networking**
21. Click the **Create Route** button
22. In **Name** type **demo**
23. In **Hostname** type in **demo.apps.lab.okd.local**
    - Note that the hostname contains **apps.lab.okd.local** this is a must since this is the DNS part of our cluster.
24. In **Path** type **/**
25. Click on the pulldown under **Service** and select **example**
26. Click on the pulldown under **Target port** and select **80 -> 8080**
27. Click the **Create** button
28. In the next page you'll see the detail about the route, including the **Location** link.  Click that link and you should see **Hello OpenShift!**

**WELL DONE**

All is good and happy playing.

NOW TO SEE IF AWS can do a repeatable infra like this without depending on RHEL.


## Hints

**NOTE** 
During install make sure you modify the /etc/nsswitch.conf file on the 2 OpenShift nodes, it causes problems with temporary name resolution failures in the logs, and you can't curl.
The line for **hosts** should be;
```
hosts:     files myhostname dns
```

The actual install can take up to an hour if not slightly longer.

Once the **bootstrap** server shows;
```
Mar 26 16:50:20 okd4-bootstrap.lab.okd.local kubelet.sh[2045]: I0326 16:50:20.282710    2045 kubelet_getters.go:182] "Pod status updated" pod="openshift-etcd/etcd-bootstrap-member-okd4-bootstrap.lab.okd.local" status=Running
Mar 26 16:50:20 okd4-bootstrap.lab.okd.local kubelet.sh[2045]: I0326 16:50:20.288236    2045 kubelet_node_status.go:590] "Recording event message for node" node="okd4-bootstrap.lab.okd.local" event="NodeHasNoDiskPressure"
```
You should be good to start the Control Plane.

When the contol-plane is started you can use the **check-install** script (found in the services.sh file, ran on the services node to see how the cluster is coming along too).

Some good examples of output from that command;
```
DEBUG Still waiting for the cluster to initialize: Working towards 4.12.0-0.okd-2023-03-18-084815: 227 of 836 done (27% complete) 
DEBUG Still waiting for the cluster to initialize: Working towards 4.12.0-0.okd-2023-03-18-084815: 355 of 836 done (42% complete) 
DEBUG Still waiting for the cluster to initialize: Working towards 4.12.0-0.okd-2023-03-18-084815: 417 of 836 done (49% complete) 
DEBUG Still waiting for the cluster to initialize: Multiple errors are preventing progress: 
DEBUG * Cluster operators authentication, image-registry, openshift-apiserver, openshift-controller-manager are not available 
DEBUG * Could not update customresourcedefinition "performanceprofiles.performance.openshift.io" (419 of 836) 
DEBUG * Could not update oauthclient "console" (515 of 836): the server does not recognize this resource, check extension API servers 
DEBUG * Could not update role "openshift-console-operator/prometheus-k8s" (753 of 836) 
DEBUG * Could not update role "openshift-console/prometheus-k8s" (756 of 836) 
DEBUG Still waiting for the cluster to initialize: Multiple errors are preventing progress: 
DEBUG * Cluster operators authentication, image-registry, openshift-apiserver, openshift-controller-manager are not available 
DEBUG * Could not update customresourcedefinition "performanceprofiles.performance.openshift.io" (419 of 836) 
DEBUG * Could not update oauthclient "console" (515 of 836): the server does not recognize this resource, check extension API servers 
DEBUG * Could not update role "openshift-console-operator/prometheus-k8s" (753 of 836) 
DEBUG * Could not update role "openshift-console/prometheus-k8s" (756 of 836) 
DEBUG Still waiting for the cluster to initialize: Cluster operators authentication, console, openshift-controller-manager are not available 
DEBUG Still waiting for the cluster to initialize: Cluster operators authentication, console are not available 
DEBUG Still waiting for the cluster to initialize: Cluster operator console is not available 
```

**DEBUGGING** 
```
sudo journalctl -xef
```
Run this on the bootstrap and control-plane to see what's happening.

### Completed when

In the journalctl output your see;
```
Mar 26 16:55:52 console-openshift-console.apps.lab.okd.local kubenswrapper[2474]: I0326 16:55:52.365483    2474 kubelet_getters.go:182] "Pod status updated" pod="openshift-kube-controller-manager/kube-controller-manager-console-openshift-console.apps.lab.okd.local" status=Running
Mar 26 16:55:52 console-openshift-console.apps.lab.okd.local ovs-vswitchd[1162]: ovs|00342|connmgr|INFO|br-ex<->unix#559: 2 flow_mods in the last 0 s (2 adds)
Mar 26 16:55:52 console-openshift-console.apps.lab.okd.local ovs-vswitchd[1162]: ovs|00343|connmgr|INFO|br-int<->unix#13: 2 flow_mods 10 s ago (2 adds)
```
