#!/bin/bash
. ../.env
TLS_DIR=../crypto-config/peerOrganizations/org1.$DOMAIN/ca
kubectl create secret generic ca-tls --from-file=$TLS_DIR/ca.org1.$DOMAIN-cert.pem --from-file=$TLS_DIR/current_sk
