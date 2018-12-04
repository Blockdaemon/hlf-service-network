#!/bin/bash

function stop() {
    # MacOS screen is poop. "^C" does not work, we have to embed it direct like
    screen -S $1 -p 0 -X stuff $'\x03' > /dev/null || true
}

function create() {
    name=$1
    shift
    screen -dmS $name kubectl port-forward svc/$name $@
}

case "$1" in
stop)
    for i in ca-org1 orderer0 peer0-org peer1-org; do stop $i; done
    ;;
start)
    create ca-org1 7054
    create orderer0 7050
    create peer0-org1 7051 7053 # 5984
    create peer1-org1 8051:7051 8053:7053 # 6984:5984
    ;;
start-proxy)
    stop proxy
    #echo "Exporting /var/run to minikube..."
    #screen -dmS mount minikube mount /var/run:/mnt1
    echo "Starting proxy for dashboard..."
    screen -dmS proxy kubectl proxy
    echo "Dashboard will be at:"
    echo "http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/"
    ;;
stop-proxy)
    stop mount
    stop proxy
    ;;
status)
    screen -ls
    ;;
"")
    $0 stop
    $0 start
    $0 status
    ;;
*)
    echo "usage: $0 [start|stop|start-proxy|stop-proxy|status]"
    ;;
esac
