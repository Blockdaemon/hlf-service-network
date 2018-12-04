# Kubernetes Instructions

## Install prerequisites

### MacOS

#### Install utils and `kubectl`, `minikube`, and `vmware-fusion`

Note: *We need `gsed -r` from coreutils because BSD `sed -E` is a POS.*

```bash
brew install coreutils ipcalc kubectl
brew cask install minikube
```

### Install VMWare Fusion

* Download from <https://www.vmware.com/products/fusion/fusion-evaluation.html>
* Get key from 1Password -> Vault: Development -> VMware Fusion Pro 11

### Debian/Ubuntu

#### Install utils and `kubectl`, `minikube`, and `kvm2` driver

```bash
sudo apt install ipcalc screen
sudp apt install qemu-kvm libvirt-clients libvirt-daemon-system
sudo adduser $USER libvirt
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-stretch main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update; sudo apt install kubectl
wget https://github.com/kubernetes/minikube/releases/download/v0.30.0/minikube_0.30-0.deb
sudo dpkg -i minikube_0.30-0.deb
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 && chmod +x docker-machine-driver-kvm2 && sudo mv docker-machine-driver-kvm2 /usr/local/bin
```

## Start `minikube` and web proxy

```bash
make start
```

This might take a LONG time to start up.

Frontend will *eventually* be on <http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy>

## Getting stuff running

* Run the various `01-...sh` scripts

## Misc stuff

### Changing `minikube` driver

* Change the `Makefile` `DRIVER_xxxx` variable

### `make` recipies

* `make delete-deps`: Remove all deployments in `hlf-service-network` namespace
* `make delete-pods`: Remove all pods in `hlf-service-network` (they will be restarted if in a deployment)
* `make start`: Start up `minikube` and `minikube` proxy
* `make stop`: Stop `minikube`
* `make nuke`: Kill everything `minikube` related. Use if you change vm driver

### `minikube` forwarder utilities

* `./forwarding.sh`: Start the fabric port forwarders
* `./forwarding.sh stop-proxy`: Start the `minikube` proxy
* `./forwarding.sh stop`: Stop the fabric port forwarders
* `./forwarding.sh stop-proxy`: Stop the `minikube` proxy

## Troubleshooting

* `./add-debugging.sh`: Add various debugging containers
* `./pod-log.sh <pod>`: Follow the log of a pod by appname (e.g. `./pod-log.sh fabric-ca`)
* `./pod-shell.sh [cmd]`: Execute `cmd` in a pod. `/bin/bash` is the default (`/bin/sh` for busybox)
* `./pod-delete.sh <pod>`: Delete a pod by app name (it will be restarted if in a deployment)

### Accessing the fabric-ca API for troubleshooting

    curl https://127.0.0.1:7054/api/v1/cainfo -vk
