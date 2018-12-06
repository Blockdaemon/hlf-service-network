#!/bin/bash

REV=1 # bump if we need to

TAG="blockdaemon.io/hlf-patch-rev"

TMPDIR="coredns/tmp"

# some versions of minikube have kube-dns and coredns BOTH installed.
# remove kube-dns, we want coredns anyway
# https://github.com/kubernetes/minikube/issues/3233#issuecomment-429787213
kubectl delete deployment kube-dns --namespace kube-system > /dev/null 2>&1

OBJ="configmap coredns --namespace kube-system"

ETAG=$(echo ${TAG} | sed -e 's/\./\\./')
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
	if [ "$1" != "-f" ]; then exit; fi
    fi
fi

mkdir -p $TMPDIR
rm -f $TMPDIR/*

# Get backup of 0
#echo Getting Corefile-v0
kubectl get $OBJ -o jsonpath={.data.Corefile-v0} > $TMPDIR/Corefile-v0

# Get current (maybe v0)
#echo Getting current to Corefile-v$currev
kubectl get $OBJ -o jsonpath={.data.Corefile} > $TMPDIR/Corefile-v$currev
if [ "$wantrev" != 0 ]; then
    cp -f Corefile $TMPDIR/Corefile
fi

# Check if we got v0 from either current or a backup
if [ ! -s $TMPDIR/Corefile-v$currev ]; then
    echo 'WARNING! No current Corefile! Restoring Corefile -v0 from backup'
    cp coredns/dist/Corefile $TMPDIR/Corefile-v0
    currev=0
fi

echo "Setting Corefile(s) to $(ls -1 $TMPDIR)"
kubectl create $OBJ \
    --from-file=$TMPDIR/ \
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
