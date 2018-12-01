# Install prerequisites
## MacOS
### Install `kubectl` and `minikube`
```
brew install kubectl
brew cask install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit && sudo install -o root -g wheel -m 4755 docker-machine-driver-hyperkit /usr/local/bin/
```

### Install `helm`
```
brew install kubernetes-helm
```

### Misc
We need `gsed -r` because BSD `sed -E` is a POS.
```
brew install coreutils
```

## Debian/Ubuntu
### Install `kubectl` and `minikube`
```
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system
sudo adduser $USER libvirt
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-stretch main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update; sudo apt install kubectl
wget https://github.com/kubernetes/minikube/releases/download/v0.30.0/minikube_0.30-0.deb
sudo dpkg -i minikube_0.30-0.deb
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 && chmod +x docker-machine-driver-kvm2 && sudo mv docker-machine-driver-kvm2 /usr/local/bin
```

### Install `helm`
```
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
helm init
```

# Start minikube and web proxy
```
minikube start --vm-driver=hyperkit
kubectl proxy
```
or just
```
00-init.sh
```
Frontend will be on http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy

Leave this little guy running in a shell.

# Blow away kube-dns
By default, both `kube-dns` and `coredns` are often installed. They like to fight.
We need `coredns` more than `kube-dns`.

https://github.com/kubernetes/minikube/issues/3233#issuecomment-429787213
```
kubectl delete deployment kube-dns --namespace kube-system
```

# Getting stuff running

Run the various `01-...sh` scripts, then

```
./deploy.sh
./services.sh
```

# Accessing the fabric-ca API for troubleshooting

Start the forwarder:

    kubectl port-forward svc/ca-org1 7054:7054

Send a request

    curl https://127.0.0.1:7054/api/v1/cainfo -vk
