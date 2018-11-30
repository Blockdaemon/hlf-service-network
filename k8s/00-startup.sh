#!/bin/bash
minikube start --vm-driver=hyperkit
echo "Starging dash proxy.. leave running in a shell!"
exec kubectl proxy
