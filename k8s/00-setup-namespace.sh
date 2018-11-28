#!/bin/bash
HSN_HOME=$(realpath $(dirname $0))/..
. $HSN_HOME/.env

kubectl create -f $HSN_HOME/namespace.json
kubectl config set-context dev --namespace=hlf-service-network --cluster=minikube --user=minikube
kubectl config use-context dev
