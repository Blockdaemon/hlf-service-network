#!/bin/bash

kubectl run hostnames --image=k8s.gcr.io/serve_hostname \
                        --labels=app=hostnames \
                        --labels=role=debug \
                        --port=9376 \
                        --replicas=3

#kubectl delete service hostnames
kubectl expose deployment hostnames --type NodePort --port=80 --target-port=9376 --labels=role=debug

kubectl apply -f debug.yaml

# FIXME this sucks
./pod-shell.sh alpine /bin/sh -c 'apk update; apk add bash curl bind-tools'
