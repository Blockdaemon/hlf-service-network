#!/bin/bash

kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin # --user nye@blockdaemon.com

kubectl scale --replicas=0 deployment/kube-dns-autoscaler --namespace=kube-system
kubectl scale --replicas=0 deployment/kube-dns --namespace=kube-system

kubectl apply -f coredns.yaml
