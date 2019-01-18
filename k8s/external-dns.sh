#!/bin/bash

TSIG_SECRET="fillmein"

. functions
read-env

function set-secret () {
    kubectl create secret generic $@ --save-config --dry-run -o json | kubectl apply -f -
}

function set-configmap() {
    kubectl create configmap $@ --save-config --dry-run -o json | kubectl apply -f -
}

set-secret external-dns-creds --from-literal="tsig-keyname=ddns-update" --from-literal="tsig-secret=${TSIG_SECRET}"
set-configmap external-dns --from-literal="zone=${DOMAIN}." --from-literal="host=ns.${DOMAIN}"

kubectl create -f "$HSN_HOME/k8s/external-dns.yaml" --save-config --dry-run -o json | kubectl apply -f -

