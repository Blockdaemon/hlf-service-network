#!/bin/bash

set -xe

helm install orderer --set DomainName=hlf.blockdaemon.io
helm install peer --set PeerName=peer0 --set OrgName=prod --set DomainName=hlf.blockdaemon.io
helm install peer --set PeerName=peer1 --set OrgName=prod --set DomainName=hlf.blockdaemon.io
