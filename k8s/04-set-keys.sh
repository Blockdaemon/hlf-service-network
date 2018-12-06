#!/bin/bash

make

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

PEM="${DOMAIN}-cert.pem"

# ca-server
CA_TLS_DIR=$CRYPTO_CONFIG/peerOrganizations/$SUBDOMAIN1.$DOMAIN/ca
set-secret ca --from-file=$CA_TLS_DIR/ca.$SUBDOMAIN1.$DOMAIN-cert.pem --from-file=$CA_TLS_DIR/current_sk

# orderer
ORDERER_DIR=$CRYPTO_CONFIG/ordererOrganizations/$DOMAIN/orderers/orderer0.$DOMAIN
# FIXME: genesis-block doesn't need to be secret?
set-secret orderer-genesis-block --from-file=$ARTIFACTS/orderer0.genesis.block

set-secret orderer-tls --from-file=$ORDERER_DIR/tls
set-configmap orderer${peer}-msp \
    --from-file="ca-cert.pem"="${ORDERER_DIR}/msp/cacerts/ca.${PEM}" \
    --from-file="tlsca-cert.pem"="${ORDERER_DIR}/msp/tlscacerts/tlsca.${PEM}"  \
    --from-file="admin-cert.pem"="${ORDERER_DIR}/msp/admincerts/Admin@${PEM}" \
    --from-file="sign-cert.pem"="${ORDERER_DIR}/msp/signcerts/orderer0.${PEM}"
set-secret orderer-msp-keystore --from-file=$ORDERER_DIR/msp/keystore

# peers
for peer in 0 1; do
    PEER_DIR=$CRYPTO_CONFIG/peerOrganizations/$SUBDOMAIN1.$DOMAIN/peers/peer${peer}.$SUBDOMAIN1.$DOMAIN
    set-secret peer${peer}-tls --from-file=$PEER_DIR/tls
    set-configmap peer${peer}-msp \
        --from-file="ca-cert.pem"="${PEER_DIR}/msp/cacerts/ca.$SUBDOMAIN1.${PEM}" \
        --from-file="tlsca-cert.pem"="${PEER_DIR}/msp/tlscacerts/tlsca.$SUBDOMAIN1.${PEM}"  \
        --from-file="admin-cert.pem"="${PEER_DIR}/msp/admincerts/Admin@$SUBDOMAIN1.${PEM}" \
        --from-file="sign-cert.pem"="${PEER_DIR}/msp/signcerts/peer${peer}.$SUBDOMAIN1.${PEM}"
    set-secret peer${peer}-msp-keystore --from-file=$PEER_DIR/msp/keystore

    # couchdb
    CDUSER=$(openssl rand -base64 32 | tr -cd '[:alpha:]')
    CDPASS=$(openssl rand -base64 32 | tr -cd '[:alpha:]')
    set-secret couchdb${peer}-creds \
        --from-literal="user=${CDUSER}" \
        --from-literal="password=${CDPASS}"
done
