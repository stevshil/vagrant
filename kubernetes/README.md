Setting up a Kubernetes cluster

The output from the kubeadm init command;
```
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/
```

Kubernetes WEB UI
```
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
```

See https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

https://kubernetes.io/docs/reference/kubectl/cheatsheet/

https://kubernetes.io/docs/reference/kubectl/docker-cli-to-kubectl/
