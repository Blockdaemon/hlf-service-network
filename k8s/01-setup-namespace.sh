#!/bin/bash

. functions

kubectl apply -f $HSN_HOME/k8s/namespace.json
kubectl config set-context $(kubectl config current-context) --namespace=hlf-service-network

#kubectl config set-context dev --namespace=hlf-service-network --cluster=minikube --user=minikube
#kubectl config use-context dev
