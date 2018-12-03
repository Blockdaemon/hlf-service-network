# Kubernetes Instructions

## Install prerequisites

### MacOS

#### Install `kubectl`, `minikube`, and `vmware-fusion`

```bash
brew install kubectl
brew cask install minikube
```

* Install vmware (TODO: add instructions)

#### Misc

We need `gsed -r` because BSD `sed -E` is a POS.

```bash
brew install coreutils ipcalc
```

### Debian/Ubuntu

#### Install `kubectl`, `minikube`, and `kvm2` driver

```bash
sudo apt install ipcalc qemu-kvm libvirt-clients libvirt-daemon-system
sudo adduser $USER libvirt
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-stretch main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update; sudo apt install kubectl
wget https://github.com/kubernetes/minikube/releases/download/v0.30.0/minikube_0.30-0.deb
sudo dpkg -i minikube_0.30-0.deb
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 && chmod +x docker-machine-driver-kvm2 && sudo mv docker-machine-driver-kvm2 /usr/local/bin
```

## Start minikube and web proxy

```bash
00-init.sh
```

This might take a LONG time to start up
Frontend will *eventually* be on <http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy>

Leave this little guy running in a shell.

## Getting stuff running

Run the various `01-...sh` scripts

## Misc stuff

### Accessing the fabric-ca API for troubleshooting

Start the forwarder:

    kubectl port-forward svc/ca-org1 7054:7054

Send a request

    curl https://127.0.0.1:7054/api/v1/cainfo -vk
