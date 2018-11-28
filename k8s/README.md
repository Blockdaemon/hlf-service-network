#MacOS
```
brew install kubectl
brew cask install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit && sudo install -o root -g wheel -m 4755 docker-machine-driver-hyperkit /usr/local/bin/
minikube start --vm-driver=hyperkit
```

#Debian/Ubuntu
```
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system
sudo adduser $USER libvirt
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-stretch main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update; sudo apt install kubectl
wget https://github.com/kubernetes/minikube/releases/download/v0.30.0/minikube_0.30-0.deb
sudo dpkg -i minikube_0.30-0.deb
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
 && chmod +x docker-machine-driver-kvm2 && sudo mv docker-machine-driver-kvm2 /usr/local/bin
```