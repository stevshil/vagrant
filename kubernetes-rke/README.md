# Adding Cluster To Rancher UI

Ref: https://rancher.com/docs/rancher/v2.5/en/cluster-provisioning/registered-clusters/

* Click the burger menu button, top left
* Select Cluster management
* Click the Import Existing button
* Click Generic
* Give the cluster a unique name (lowercase DNS naming)
* Optionally add a description
* Click the Create button

* In the new screen grab the curl line
* SSH on to your RKE built cluster CONTROLLER VM
* Modify the curl command so we download the YAML file

    ```
    $ curl --insecure -sfL https://yourRancherUIPublicIP/v3/import/theweirdhashstring.yaml >rancher.yml
    ```
* Edit the rancher.yml file
    * We need to change the Rancher UI public IP to its private IP
    * Search for https:
    * Change the IP address to the 172.31….. Address of the Rancher UI VM
* Apply the configuration to link our cluster to the Rancher UI

    ```
    kubectl apply -f rancher.yml
    ```

* Now wait for the following screen to show True
    * Except Stalled = False
* Cluster is now added
* Click Clusters in the left side of the screen
* You should see your cluster now added and Active

## If it fails

* Run the following commands on the cluster controller
    * This will delete the Rancher UI configuration

        ```
        $ kubectl patch namespace cattle-system -p '{"metadata":{"finalizers":[]}}' --type='merge' -n cattle-system
        $ kubectl delete namespace cattle-system --grace-period=0 --force
        ```
* Delete the cluster in the Rancher UI
* Redo making sure private IP address is changed



