#!/bin/bash

set -e

echo "Setting up routes, may need sudo passwd:"

echo "Adding route to cluster"
cip=$(kubectl get svc --namespace default kubernetes -o jsonpath='{.spec.clusterIP}')
if [ -z "$cip" ]; then
    echo "can't figure out ClusterIP, aborting"
    exit 1
fi
if [ "$cip" != "10.96.0.1" ]; then
    echo "unexpected ClusterIP \"$cip\", aborting"
    exit 1
fi

sudo route -q delete 10.96.0.0/12 > /dev/null 2>&1
sudo route add 10.96.0.0/12 $(minikube ip)

exit
# vmwarefusion aready does this for us
# hyperkit is broken regardless

echo "Adding route to nodes"
cidr=$(grep HostOnlyCIDR ~/.minikube/profiles/minikube/config.json | cut -f 4 -d \")
if [ -z "$cidr" ]; then
    echo "can't figure out host CIDR, aborting"
    exit 1
fi

if [ -x "$(command -v ipcalc)" ]; then
    cidr=$(ipcalc -nb $cidr | grep ^Network: | cut -f 2 -d ":")
else
    cidr=$(echo $cidr | sed -E 's/\.[0-9]+(\/[0-9]+)/.0\1/')
fi

# broken - HostOnlyCIDR has no meaning in hyperkit?
echo sudo route -q delete ${cidr} > /dev/null 2>&1
echo sudo route add ${cidr} $(minikube ip)
