# How to run

## Install Helm

* debian: `curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash`
* MacoS: `brew install kubernetes-helm`
* `helm init`

## Generate required files

Generate certs, keys and other data in the root directory:

    make -C ..

Please note that this currently creates files for:

- Two peers
- One solo orderer
- ...

When we want to add more than two peers we need to first make this part more dynamic.

## Bring up minikube

Have a look at `../k8s/README.md` for details.

Run the following commands (some of which are workarounds):

    pushd ../k8s
    ./01-setup-namespace.sh # Creates the k8s namespace
    ./02-patch-minikube.sh # To allow pods to talk to themselves
    ./03-patch-coredns.sh # Make sure the HL internal domains resolve
    popd

Add configs and secrets (the stuff we generated using `make`):

    pushd ../k8s
    ./04-set-keys.sh
    popd

# Start orderer and peers

Run:

    ./start.sh

to bring up one orderer and two peers.

# Set up forwarders

minikube only - real k8s will use something different.

    ./forwarding.sh

This will start forwarders to all services in `screen`.

# Test it

Run https://github.com/Blockdaemon/hlf-database-app according to its instructions

# Delete all deployments

    helm ls --short | xargs -L1 helm delete
