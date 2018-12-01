#!/bin/bash

# TODO: these all just block

# lets just print out the commands we would use

echo kubectl port-forward svc/ca-org1 7054:7054
echo kubectl port-forward svc/orderer0 7050:7050

echo kubectl port-forward svc/peer0-org1 7051:7051
echo kubectl port-forward svc/peer0-org1 7053:7053
echo kubectl port-forward svc/peer0-org1 5984:5984

echo kubectl port-forward svc/peer1-org1 8051:7051
echo kubectl port-forward svc/peer1-org1 8053:7053
echo kubectl port-forward svc/peer1-org1 6984:5984
