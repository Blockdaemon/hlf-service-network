#!/bin/bash

#kubectl run hostnames --image=k8s.gcr.io/serve_hostname \
#                        --labels=app=hostnames \
#                        --port=9376 \
#                        --replicas=3
#
#kubectl expose deployment hostnames --port=80 --target-port=9376

kubectl apply -f debug.yaml
