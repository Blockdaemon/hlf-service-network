#!/bin/bash

minikube addons enable ingress

#kubectl run minikube-lb-patch --replicas=1 --image=elsonrodriguez/minikube-lb-patch:0.1 --namespace=kube-system

kubectl create -f nginx-ingress.yaml --save-config --dry-run -o json | kubectl apply -f -
