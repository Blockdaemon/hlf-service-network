#!/bin/bash

. ../k8s/functions

read-env

set -xe

helm install orderer --set HLFTag="${HLF_ARCH}-${HLF_VERSION}" --set DomainName=${DOMAIN}
helm install peer --set HLFTag="${HLF_ARCH}-${HLF_VERSION}" --set PeerNum=0 --set OrgName=${SUBDOMAIN1} --set DomainName=${DOMAIN}
helm install peer ---set HLFTag="${HLF_ARCH}-${HLF_VERSION}" -set PeerNum=1 --set OrgName=${SUBDOMAIN1} --set DomainName=${DOMAIN}
