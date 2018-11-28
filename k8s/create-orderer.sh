#!/bin/bash
HSN_HOME=$(realpath $(dirname $0))/..

kubectl create -f "$HSN_HOME/k8s/orderer.yaml" --save-config
