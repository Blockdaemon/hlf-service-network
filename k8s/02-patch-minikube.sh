#!/bin/bash

# Patch to enable LoadBalancer
kubectl run minikube-lb-patch --replicas=1 --image=elsonrodriguez/minikube-lb-patch:0.1 --namespace=kube-system

# https://github.com/kubernetes/minikube/issues/1568
# Allow hosts to talk to themselves
minikube ssh sudo ip link set docker0 promisc on
