#!/bin/bash

set -xe

helm install orderer
helm install peer --set PeerName=peer0 --set OrgName=prod
helm install peer --set PeerName=peer1 --set OrgName=prod
