#!/bin/bash
if [ -z "$GOPATH" ]; then
	GOPATH=~/go
fi

exec minikube mount $GOPATH/src/github.com/Blockdaemon/hlf-service-network/crypto-config:/crypto-config
