#!/bin/bash

kubectl run hostnames --image=k8s.gcr.io/serve_hostname \
                        --labels=app=hostnames \
                        --labels=role=debug \
                        --port=9376 \
                        --replicas=3

kubectl expose deployment hostnames --port=80 --target-port=9376 --labels=role=debug

kubectl apply -f debug.yaml
