#!/bin/bash

. functions
if [ -z "$1" ]; then
    echo "usage: $0 <pod>"
    list-pods
    exit 1
fi

exec kubectl delete pod -l app=$1
