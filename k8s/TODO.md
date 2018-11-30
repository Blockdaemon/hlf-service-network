# TODO
* Put orderer genesis block in `configMap`?
* Make `org1` white-boxable
* Put more scripts into `Makefile`? We can automatically know if a yaml changed, why not apply?
* Install nginx with ssl-passthrough
  * https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#ssl-passthrough
```
helm install stable/nginx-ingress --namespace kube-system \
--set controller.hostNetwork=true,controller.kind=DaemonSet,rbac.create=true
```
