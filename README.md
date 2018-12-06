# hlf-service-network

Skeleton for building a simple Hyperledger Fabric service network

* Docker containers for one ca server, one orderer and two peers
* Three self signed Org CA's - one top level (orderer) and two sub orgs (one unused)
* MSP certs for one orderer and two peers (peers are in ONE of the two sub orgs)
* MSP certs for one admin and two users (first suborg)
* MSP certs for one admin and one users (second suborg, unused)
* Orderer genesis block
* Makefile targets for one channel genesis block and an anchor peers update for it

Note the the channel genesis block and anchor peer updates are not used by
`hlf-service-network`, they are intended for use by a client.

## Prerequisites

* Docker
* docker-compose
* GNU make
* curl
* Python3
* Python3 jinja2

### MacOS

* [Install docker](https://store.docker.com/editions/community/docker-ce-desktop-mac)
* Install other stuff:

```bash
brew install python3
pip3 install jinja2
```

### Ubuntu/Debian

* [Install docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository)
* Install other stuff:

```bash
apt install make curl python3-jinja2
```

## QUICKSTART

```bash
make
make up
```

## To clean up

```bash
make clean
```

## Start up with persistent storage

```bash
make persistent
```

## Make channel genesis block and anchor peers update

```bash
make channel
make anchor-peers
```

## Overriding default config.mk

You can put overrides in local.mk

## couchdb access

* db0 [http://localhost:5984](http://localhost:5984)
* db1 [http://localhost:6984](http://localhost:6984)

l/p: `cdbadmin`/`cdbadminpw`

## Bugs

* Artifacts may not be compatible across versions. Do a `make clean` if you change `HLF_VERSION`!

* The Hyperledger Fabric docker image tags changed format between 1.0.5 and 1.2.0:
  * 1.0.5 only has `x86_64` tags
  * 1.1.0 has `x86_64` and `amd64` tags
  * 1.2.0 only has `amd64` tags

## References

See also [How to build your first Hyperledger fabric network](https://chainhero.io/2018/04/tutorial-hyperledger-fabric-how-to-build-your-first-network/)
