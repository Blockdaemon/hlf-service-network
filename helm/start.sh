#!/bin/bash

set -xe

helm install orderer --set DomainName=hlf.blockdaemon.io
helm install peer --set PeerNum=0 --set OrgName=prod --set DomainName=hlf.blockdaemon.io
helm install peer --set PeerNum=1 --set OrgName=prod --set DomainName=hlf.blockdaemon.io
