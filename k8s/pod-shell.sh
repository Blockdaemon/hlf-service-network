#!/bin/bash

. functions
if [ -z "$1" ]; then
    echo "usage: $0 <pod>"
    exit 1
fi

find-pod POD $1

if [ -z "$POD" ]; then
    echo "Can't find pod '$1'"
    exit 1
fi

exec kubectl exec -ti $POD /bin/bash
