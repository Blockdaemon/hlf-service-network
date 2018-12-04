#!/bin/bash

# https://github.com/kubernetes/minikube/issues/1568
# Allow hosts to talk to themselves

exec minikube ssh sudo ip link set docker0 promisc on
