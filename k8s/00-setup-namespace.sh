#!/bin/bash
kubectl create -f namespace.json
kubectl config set-context dev --namespace=hlf-service-network --cluster=minikube --user=minikube
kubectl config use-context dev
