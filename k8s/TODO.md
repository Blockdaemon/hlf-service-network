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
* Automatically `apk add bash curl bind-tools` to alpine container
* 03-patch-coredns.sh is a big honking mess
  * https://coredns.io/2017/05/08/custom-dns-entries-for-kubernetes/
  * https://github.com/coredns/coredns/tree/master/plugin/rewrite
  * Corefile.diff has hardcoded domain in it. Can't make it work because it has to escape \.
  * coredns is tied to minicube - we likely need to write a stub that will do CNAMEs for us that is provier independent
