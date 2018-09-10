# hlf-service-network
Skeleton for building a simple Hyperledger Fabric service network
* Self signed Org CA
* Certs and containers for one orderer and two peers
* Peer anchor
* Certs for one admin and two users
* Orderer genesis block
* One channel

# Prerequisites
* Docker
* docker-compose
* GNU make
* curl
* Python3
* Python3 jinja2

## MacOS
* [Install docker](https://store.docker.com/editions/community/docker-ce-desktop-mac)
* Install other stuff:
```
brew install python3
pip3 install jinja2
```

## Ubuntu/Debian
* [Install docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository)
* Install other stuff:
```
apt-get install make curl
apt-get install python3-jinja2
```

# QUICKSTART
```
make
make up
```

# To clean up
```
make clean
```

# Start up with persistent storage
```
make persistent
```

# Overriding default config.mk

You can put overrides in local.mk

# couchdb access

* db0 [http://localhost:5984](http://localhost:5984)
* db1 [http://localhost:6984](http://localhost:6984)

l/p: `cdbadmin`/`cdbadminpw`

# Bugs

* Artifacts may not be compatible across versions. Do a `make clean` if you change `HLF_VERSION`!

* The Hyperledger Fabric docker image tags changed format between 1.0.5 and 1.2.0:
  * 1.0.5 only has `x86_64` tags
  * 1.1.0 has `x86_64` and `amd64` tags
  * 1.2.0 only has `amd64` tags

* The following sequence fails
```
make clean
make
touch Makefile
make
```
with
```
[common/tools/configtxgen] main -> INFO 001 Loading configuration
[common/tools/configtxgen] doOutputBlock -> INFO 002 Generating genesis block
[common/tools/configtxgen] doOutputBlock -> INFO 003 Writing genesis block
FABRIC_CFG_PATH=/Users/nyet/src/hlf-service-network tools/Darwin-i386/1.1.0/bin/configtxgen -profile Blockdaemon -outputCreateChannelTx artifacts/blockdaemon.channel.tx -channelID blockdaemon
[common/tools/configtxgen] main -> INFO 001 Loading configuration
[common/tools/configtxgen] doOutputChannelCreateTx -> INFO 002 Generating new channel configtx
[common/tools/configtxgen] main -> CRIT 003 Error on outputChannelCreateTx: config update generation failure: could not parse application to application group: setting up the MSP manager failed: the supplied identity is not valid: x509: certificate signed by unknown authority (possibly because of "x509: ECDSA verification failure" while trying to verify candidate authority certificate "ca.org1.hf.blockdaemon.io")
```

# References
See also [How to build your first Hyperledger fabric network](https://chainhero.io/2018/04/tutorial-hyperledger-fabric-how-to-build-your-first-network/)
