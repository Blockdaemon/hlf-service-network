# TODO

* Put orderer genesis block in `configMap`?
* Make `org1` white-boxable
* Put more scripts into `Makefile`? We can automatically know if a yaml changed, why not apply?
* Automatically `apk add bash curl bind-tools` to alpine container via something sane
* 03-patch-coredns.sh is a big honking mess
  * <https://coredns.io/2017/05/08/custom-dns-entries-for-kubernetes/>
  * <https://github.com/coredns/coredns/tree/master/plugin/rewrite>
  * Corefile.diff has hardcoded domain in it. Can't make it work because it has to escape \.
  * `coredns` is tied to minicube - we likely need to write a stub that will do CNAMEs for us that is provider independent
  * Possibly back up old versions in configMap?

## Misc junk

#### builtin minikube nginx-ingress

```bash
minikube addons enable ingress
```

### hyperkit driver (MACOS)

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit && sudo install -o root -g wheel -m 4755 docker-machine-driver-hyperkit /usr/local/bin/
```

### Helm

* debian: `curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash`
* MacoS: `brew install kubernetes-helm`
* `helm init`

#### nginx-ingress from helm

```bash
minikube addons disable ingress
helm install stable/nginx-ingress --namespace kube-system \
--set controller.hostNetwork=true,controller.kind=DaemonSet,rbac.create=true
```
