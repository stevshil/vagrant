#!/bin/bash

# Script to initialise the services in the cluster
for file in services-ns.yaml registry-pv.yaml registry-pvc.yaml registry.yaml jenkins.yaml jenkins-service.yaml
do
  kubectl apply -f $file
done
