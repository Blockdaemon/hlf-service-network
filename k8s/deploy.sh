#!/bin/bash

. functions

function deploy() {
    for i in $@; do
	kubectl create -f "$HSN_HOME/k8s/$i.yaml" --save-config --dry-run -o json | kubectl apply -f -
    done
}

if [ $# != 1 ]; then
    deploy ca-server orderer peers
    exit 0
fi

what=$(basename $1 .yaml)

if [ ! -r "$HSN_HOME/k8s/$what.yaml" ]; then
    echo "can't read \"$HSN_HOME/k8s1/$what.yaml\""
    exit 1
fi

deploy $what
