#!/bin/bash

docker build -t $1/jenkins:0.1 -f Dockerfile.jenkins .
