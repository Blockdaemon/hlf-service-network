#!/bin/bash

. functions
read-env

ARTIFACTS=$HSN_HOME/artifacts
CRYPTO_CONFIG=$HSN_HOME/crypto-config

function set-secret () {
    kubectl create secret generic $@ --save-config --dry-run -o json | kubectl apply -f -
}

function set-configmap() {
    kubectl create configmap $@ --save-config --dry-run -o json | kubectl apply -f -
}

# ca-server
CA_TLS_DIR=$CRYPTO_CONFIG/peerOrganizations/org1.$DOMAIN/ca
set-secret ca --from-file=$CA_TLS_DIR/ca.org1.$DOMAIN-cert.pem --from-file=$CA_TLS_DIR/current_sk

# orderer
ORDERER_DIR=$CRYPTO_CONFIG/ordererOrganizations/$DOMAIN/orderers/orderer0.$DOMAIN
set-secret orderer-genesis-block --from-file=$ARTIFACTS/orderer0.genesis.block
set-secret orderer-tls --from-file=$ORDERER_DIR/tls
set-configmap orderer${peer}-msp \
    --from-file="ca-cert.pem"="${ORDERER_DIR}/msp/cacerts/ca.${DOMAIN}-cert.pem" \
    --from-file="tlsca-cert.pem"="${ORDERER_DIR}/msp/tlscacerts/tlsca.${DOMAIN}-cert.pem"  \
    --from-file="admin-cert.pem"="${ORDERER_DIR}/msp/admincerts/Admin@${DOMAIN}-cert.pem" \
    --from-file="peer-cert.pem"="${ORDERER_DIR}/msp/signcerts/orderer0.${DOMAIN}-cert.pem"
set-secret orderer-msp-keystore --from-file=$ORDERER_DIR/msp/keystore

# peers
for peer in 0 1; do
    PEER_DIR=$CRYPTO_CONFIG/peerOrganizations/org1.$DOMAIN/peers/peer${peer}.org1.$DOMAIN
    set-secret peer${peer}-tls --from-file=$PEER_DIR/tls
    set-configmap peer${peer}-msp \
        --from-file="ca-cert.pem"="${PEER_DIR}/msp/cacerts/ca.org1.${DOMAIN}-cert.pem" \
        --from-file="tlsca-cert.pem"="${PEER_DIR}/msp/tlscacerts/tlsca.org1.${DOMAIN}-cert.pem"  \
        --from-file="admin-cert.pem"="${PEER_DIR}/msp/admincerts/Admin@org1.${DOMAIN}-cert.pem" \
        --from-file="peer-cert.pem"="${PEER_DIR}/msp/signcerts/peer${peer}.org1.${DOMAIN}-cert.pem"
    set-secret peer${peer}-msp-keystore --from-file=$PEER_DIR/msp/keystore
done
