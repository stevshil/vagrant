#!/bin/bash

wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
tar xvf helm-v3.6.3-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/helm
rm -fr linux-amd64
