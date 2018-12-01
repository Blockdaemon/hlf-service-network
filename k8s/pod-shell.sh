#!/bin/bash

. functions
if [ -z "$1" ]; then
    echo "usage: $0 <pod> [command]"
    list-pods
    exit 1
fi

find-pod POD $1

if [ -z "$POD" ]; then
    echo "Can't find pod '$1'"
    exit 1
fi

if [ "$POD" = "busybox" ] ; then
    CMD=/bin/sh
else
    CMD=/bin/bash
fi

if [ ! -z "$2" ];  then
    CMD=$2
fi

exec kubectl exec -ti $POD $CMD
