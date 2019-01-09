#!/bin/bash

# Patch to enable LoadBalancer
# https://github.com/elsonrodriguez/minikube-lb-patch
kubectl run minikube-lb-patch --replicas=1 --image=elsonrodriguez/minikube-lb-patch:0.1 --namespace=kube-system
#sudo route -n add -net $(cat ~/.minikube/profiles/minikube/config.json | jq -r ".KubernetesConfig.ServiceCIDR") $(minikube ip)

# Allow hosts to talk to themselves
# https://github.com/kubernetes/minikube/issues/1568
minikube ssh sudo ip link set docker0 promisc on
