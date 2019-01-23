# TODO

* Switch as much as possible to yaml
* Put orderer genesis block in `configMap`?
* Put more scripts into `Makefile`? We can automatically know if a yaml changed, why not apply?
* Automatically `apk add bash curl bind-tools` to alpine container via something sane (e.g. wait for liveness, build real container, etc)
* ##-patch-coredns.sh is a big honking mess
  * <https://coredns.io/2017/05/08/custom-dns-entries-for-kubernetes/>
  * <https://github.com/coredns/coredns/tree/master/plugin/rewrite>
  * `coredns` is tied to minicube - we likely need to write a stub that will do CNAMEs for us that is provider independent
* Figure out what's secret about secrets. E.g. can peers access the root ca key (which would be really bad)
* Solve split horizon problem (internal/external DNS)
* Services don't ping. k8s sucks. Again.
* Pod can't contact self via service IP, either from proper hostname (e.g. `peer0.org1.hlf.blockdaemon.com`) or service hostname (`peer0-org1.hlf-service-network.cluster.local`)
  * <https://github.com/kubernetes/minikube/issues/1568> (set vm interface to promisc) solves this
  * k8s can't properly set pod's own hostname to something real via `spec.hostname` and `spec.domain`, you have to use their idiotic DNS conventions
  * Results in vmware-fusion and hyperkit differ:
    * vmware does the "right" thing, sets both hostname and domain to the "correct" (but still broken) k8s service DNS (e.g. `peer0.org1` vs `peer0-org1`)
    * hyperkit totally ignores `spec.hostname` and `spec.domain`. Nice going.
* Triage problems between minikube/hypervisor specific and kubernetes in general
* Peer chaincode containers are currently spun up on the host vm docker and kubernetes is totally unaware of it.
  * If pod goes down, nobody knows the chaincode container should be killed with it.
  * Docker in Docker sucks - https://jira.hyperledger.org/browse/FAB-7406
* Persistence for everyone in k8s
  * see also `../docker-compose-persistent.yaml`
* Document `external-dns`

## Research topics

* Hyperledger organizational interoperability
* Hyperledger aaS interoperability
* Hyperledger `cello`
* Competitors/potential partners
  * IBM, AWS...?

## Miscellaneous

### Install VMWare Fusion

* Download from <https://www.vmware.com/products/fusion/fusion-evaluation.html>
* Get key from 1Password -> Vault: Development -> VMware Fusion Pro 11

### Enable builtin minikube nginx-ingress

```bash
minikube addons enable ingress
```
