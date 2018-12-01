#!/bin/bash

function expose() {
    kubectl expose deployment "$1" "--port=$2" "--name=$3" --save-config --dry-run -o json | kubectl apply -f -
}

expose fabric-ca-deployment 7054 ca-org1
expose fabric-orderer-deployment 7050 orderer0

for i in 0 1; do
    expose fabric-peer${i}-deployment 7051,7053 peer${i}-org1 # no couchdb
    # expose fabric-peer${i}-deployment 7051,7053,5984 peer${i}-org1 # with couchdb
done
