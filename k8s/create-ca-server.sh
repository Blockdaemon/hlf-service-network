#!/bin/bash

. functions

exec kubectl create -f "$HSN_HOME/k8s/ca-server.yaml" --save-config
