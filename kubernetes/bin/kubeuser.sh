#!/bin/bash

# These commands must be ran as a regular user and not root

export KUBERNETES_MASTER=http://192.168.205.10:8080
# On the master only
if hostname | grep kubemaster >/dev/null 2>&1
then
  # Run the following as a regular user on master
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  # Make a cross system copy of kube-config
  rm -f /vagrant/kube-config
  cp $HOME/.kube/config /vagrant/kube-config

  # export KUBECONFIG=/etc/kubernetes/admin.conf

  # install Calico pod network addon
  kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
  kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

  kubectl taint nodes --all node-role.kubernetes.io/master-

  # Not working
  #kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
  #kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
  # kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')
  # kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  #kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
  # Alternatives to above
  #kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
  #kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

  # This one gets the networking ready and prevents the error about the CNI network not being ready
  # kubectl apply -f https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/calico.yaml

  #For RHEL need to remove the following from CoreDNS configuration which will then enable DNS
  # allowPrivilegeEscalation: false
  # kubectl -n kube-system edit deployment coredns
  # Automated method doesn't work
  # kubectl patch deployment -n=kube-system coredns -p '{"spec": {"containers": {"securityContext":{"allowPrivilegeEscalation": true}}}}'
  if [[ -e /etc/redhat-release ]]
  then
    kubectl -n kube-system get deployment coredns -o yaml | \
    sed 's/allowPrivilegeEscalation: false/allowPrivilegeEscalation: true/g' | \
    kubectl apply -f -
  fi

  # Get DNS pod configuration
  # for dns in $(kubectl get pods --namespace=kube-system |grep coredns | awk '{print $1}')
  # do
  #   kubectl get pods --namespace=kube-system $dns -o json | sed 's/allowPrivilegeEscalation.*/allowPrivilegeEscalation": true,/' >${dns}
  #   kubectl apply -f ${dns}
  #   rm ${dns}
  # done
  #
  # Restart the DNS pods
  # for x in `kubectl get pods --all-namespaces | awk '{print $2}' | grep 'coredns'`
  # do
  #  kubectl delete pod $x -n kube-system
  # done

  kubectl get nodes
  kubectl get pods --all-namespaces
fi
