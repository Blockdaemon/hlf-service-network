#!/bin/bash
REV=1 # bump if we need to

# SIGH
ETAG="blockdaemon\\.io/hlf-patch-rev"
TAG="blockdaemon.io/hlf-patch-rev"

set -e

OBJ="configmap coredns --namespace kube-system"

rev=$(kubectl get $OBJ -o jsonpath="{.metadata.annotations.${ETAG}}")

if [ "$1" = "-r" ]; then
    if [ -z "$rev" ]; then
        echo "not patched"
        exit
    fi
    ARG=-R
else
    if [ ! -z "$rev" ]; then
        echo "already at rev $rev"
        exit
    fi
    ARG=-N
fi

kubectl get $OBJ -o jsonpath={.data.Corefile} > coredns/Corefile
patch -fs $ARG -d coredns -i Corefile.diff -o Corefile-patched
kubectl create $OBJ --from-file=Corefile=coredns/Corefile-patched --dry-run --save-config -o json | kubectl apply -f -

# restore old annotation
#kubectl annotate --overwrite $OBJ "addonmanager.kubernetes.io/mode"="EnsureExists"

if [ "$1" = "-r" ]; then
    kubectl annotate $OBJ "${TAG}-"
else
    # mark that we patched this damn thing
    kubectl annotate --overwrite $OBJ "$TAG"="$REV"
fi

rm -f coredns/Corefile-patched coredns/Corefile

. coredns/kill-core
