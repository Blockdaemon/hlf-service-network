#!/bin/bash

. functions

exec kubectl create -f "$HSN_HOME/k8s/orderer.yaml" --save-config
