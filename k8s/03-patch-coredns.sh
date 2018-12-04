#!/bin/bash

REV=1 # bump if we need to

# SIGH
ETAG="blockdaemon\\.io/hlf-patch-rev"
TAG="blockdaemon.io/hlf-patch-rev"

TMPDIR="coredns/tmp"

# some versions of minikube have kube-dns and coredns BOTH installed.
# remove kube-dns, we want coredns anyway
# https://github.com/kubernetes/minikube/issues/3233#issuecomment-429787213
kubectl delete deployment kube-dns --namespace kube-system > /dev/null 2>&1

OBJ="configmap coredns --namespace kube-system"

currev=$(kubectl get $OBJ -o jsonpath="{.metadata.annotations.${ETAG}}")

if [ "$1" = "-r" ]; then
    # try to revert
    if [ -z "$currev" ]; then
        echo "Not patched, can't revert"
        exit
    fi
    # we want rev 0
    wantrev=0
else
    # want new stuff
    wantrev=$REV
    if [ -z "$currev" ]; then
	currev=0
    fi
    if [ "$REV" = "$currev" ]; then
        echo "Already at rev $REV"
        exit
    fi
fi

mkdir -p $TMPDIR
rm -f $TMPDIR/*

#echo Getting Corefile-v$currev
kubectl get $OBJ -o jsonpath={.data.Corefile-v0} > $TMPDIR/Corefile-v0
#echo Getting current to Corefile-v$currev
kubectl get $OBJ -o jsonpath={.data.Corefile} > $TMPDIR/Corefile-v$currev

if [ ! -s $TMPDIR/Corefile-v$currev ]; then
    echo 'WARNING! No current Corefile! Restoring Corefile -v0 from backup'
    cp coredns/dist/Corefile $TMPDIR/Corefile-v0
    currev=0
fi

if [ "$wantrev" != 0 ]; then
    #echo Copying latest Corefile to Corefile-v$wantrev
    cp -f coredns/Corefile $TMPDIR/Corefile-v$wantrev
fi

echo Setting Corefile to Corefile-v$wantrev
kubectl create $OBJ \
    --from-file=Corefile-v0=$TMPDIR/Corefile-v0 \
    --from-file=Corefile=$TMPDIR/Corefile-v$wantrev \
    --dry-run --save-config -o json | kubectl apply -f -

# restore old annotation
#kubectl annotate --overwrite $OBJ "addonmanager.kubernetes.io/mode"="EnsureExists"

# Remove annotation if target is 0
if [ "$wantrev" = "0" ]; then
    echo "Removing version tag"
    kubectl annotate $OBJ "${TAG}-"
else
    # mark our revision
    echo "Setting version tag to $wantrev"
    kubectl annotate --overwrite $OBJ "$TAG"="$wantrev"
fi

. coredns/kill-core
