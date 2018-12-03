#!/bin/bash
make start
echo "Starting dashboard proxy.. leave running in a shell!"
echo "http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/"
exec kubectl proxy
