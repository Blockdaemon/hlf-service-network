#!/bin/bash
kubectl create -f namespace.json
kubectl config set-context dev --namespace=hlf-service-network
#  --cluster=minikube \
#  --user=$(USER)\
kubectl config use-context dev
