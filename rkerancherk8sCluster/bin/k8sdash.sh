#!/bin/bash

# Add dasboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

# Create external access
cat >/home/vagrant/np.yml <<_END_
apiVersion: v1
kind: Service
metadata:
  name: dashboard-service
  namespace: kubernetes-dashboard
spec:
  type: NodePort
  selector:
    k8s-app: kubernetes-dashboard
  ports:
    - port: 8443
      targetPort: 8443
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: dashboard-ingress
  annotations:
    ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: dashboard.k8s.tps.local
    http:
      paths:
        - path: /
          backend:
            serviceName: dashboard-service
            servicePort: 8443
_END_

kubectl apply -f /home/vagrant/np.yml

# Create dashboard user
cat >/home/vagrant/user.yml <<_END_
apiVersion: v1
kind: ServiceAccount
metadata:
  name: support
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: support
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: support
  namespace: kubernetes-dashboard
_END_
kubectl apply -f /home/vagrant/user.yml

# Token to use to login to dashboard
kubectl -n kubernetes-dashboard get secret $(kubectl --kubeconfig kube_config_cluster.yml -n kubernetes-dashboard get sa/support -o jsonpath="{.secrets[0].name}")

sudo -u vagrant mkdir /home/vagrant/bin
echo "kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/support -o jsonpath=\"{.secrets[0].name}\") -o go-template=\"{{.data.token | base64decode}}\"" >/home/vagrant/bin/getlogin
chown vagrant:vagrant /home/vagrant/bin/getlogin
chmod +x /home/vagrant/bin/getlogin
