#!/bin/bash

. ../k8s/functions

read-env

set -xe

helm install orderer --set DomainName=${DOMAIN}
helm install peer --set PeerNum=0 --set OrgName=${SUBDOMAIN1} --set DomainName=${DOMAIN}
helm install peer --set PeerNum=1 --set OrgName=${SUBDOMAIN1} --set DomainName=${DOMAIN}
