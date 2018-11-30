#!/bin/bash

function expose() {
    kubectl expose deployment $@ --save-config --dry-run -o json | kubectl apply -f -
}

expose fabric-ca-deployment --port=7054 --name=ca
expose fabric-orderer-deployment --port=7050 --name=orderer0

for i in 0 1; do
    expose fabric-peer${i}-deployment --port=7051,7053 --name=peer${i}-org1
    #expose fabric-couch${i}-deployment --port=5984 --name=couch${i}-org1
done
