#!/bin/bash

. functions

exec kubectl create -f "$HSN_HOME/k8s/peers.yaml" --save-config
