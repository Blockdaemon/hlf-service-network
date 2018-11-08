include config.mk

# include overrides if the file exists
-include local.mk

ifndef GOPATH
    GOPATH:=$(HOME)/go
    export GOPATH
endif

export FABRIC_CFG_PATH:=$(shell pwd)

MAKEFILES:=Makefile config.mk $(wildcard local.mk)	# only care about local.mk if it is there
UNAME:=$(shell uname -s)
ARCH:=$(shell arch)

ARCHURL_Darwin-i386:=darwin-amd64
ARCHURL_Linux-x86_64:=linux-amd64
URLPATH:=$(ARCHURL_$(UNAME)-$(ARCH))
ifndef URLPATH
$(error Do not know how to handle $(UNAME)-$(ARCH))
endif
TOOLURL:=https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/$(URLPATH)-$(HLF_VERSION)/hyperledger-fabric-$(URLPATH)-$(HLF_VERSION).tar.gz

TOOLDIR:=tools/$(UNAME)-$(ARCH)/$(HLF_VERSION)
BINDIR:=$(TOOLDIR)/bin

CRYPTO_DIR:=crypto-config/peerOrganizations/org1.$(DOMAIN)
CURRENT_SK:=$(CRYPTO_DIR)/ca/current_sk
MSP_CA_PEM:=$(CRYPTO_DIR)/msp/cacerts/ca.org1.$(DOMAIN)-cert.pem
MSP_ADMIN_PEM:=$(CRYPTO_DIR)/msp/admincerts/Admin@org1.$(DOMAIN)-cert.pem

.PHONY: all
all: .env genesis channel anchor-peers

$(BINDIR)/cryptogen $(BINDIR)/configtxgen:
	mkdir -p $(TOOLDIR)
	curl -s $(TOOLURL) | tar xvz -C $(TOOLDIR) || (rm -rf $(BINDIR); false)
	@touch $(BINDIR)/cryptogen $(BINDIR)/configtxgen	# tar will extract with the old date, which will be older than README

.PHONY: crypto-ca genesis channel anchor-peers
crypto-ca: $(CURRENT_SK) $(MSP_CA_PEM) $(MSP_ADMIN_PEM)
$(CURRENT_SK) $(MSP_CA_PEM) $(MSP_ADMIN_PEM): $(BINDIR)/cryptogen crypto-config.yaml
	@rm -rf crypto-config # hack to get around configtxgen bug - make sure all certs are regenned
	@mkdir -p crypto-config
	$(BINDIR)/cryptogen generate --config=./crypto-config.yaml
	LATEST=$$(ls -1t $(CRYPTO_DIR)/ca/*_sk | head -1); [ ! -z "$$LATEST" ] && mv $$LATEST $(CURRENT_SK)

artifacts:
	@mkdir -p artifacts

genesis: artifacts/orderer0.genesis.block
artifacts/orderer0.genesis.block: $(BINDIR)/configtxgen artifacts configtx.yaml $(CRYPTO_DIR)/ca/current_sk
	@# 1.2.0 requires -channelID for genesis block, but this breaks 1.1.0
	$(BINDIR)/configtxgen -profile $(PROFILE)Solo -outputBlock $@ -channelID genesis-channel

channel: artifacts/$(CHANNEL).channel.tx
artifacts/$(CHANNEL).channel.tx: $(BINDIR)/configtxgen artifacts configtx.yaml $(MSP_CA_PEM) $(MSP_ADMIN_PEM)
	$(BINDIR)/configtxgen -profile $(PROFILE)Channel -outputCreateChannelTx $@ -channelID $(CHANNEL)

anchor-peers: artifacts/$(CHANNEL).anchor-peers.tx
artifacts/$(CHANNEL).anchor-peers.tx: $(BINDIR)/configtxgen artifacts configtx.yaml
	$(BINDIR)/configtxgen -profile $(PROFILE)Channel -outputAnchorPeersUpdate $@ -channelID $(CHANNEL) -asOrg Org1$(ORG)

# .env file for docker-compose
.env: $(MAKEFILES)
	@echo "HLF_ARCH=$(HLF_ARCH)" > $@
	@echo "HLF_VERSION=$(HLF_VERSION)" >> $@
	@echo "PROFILE=$(PROFILE)" >> $@
	@echo "DOMAIN=$(DOMAIN)" >> $@
	@echo "NETWORKID=$(NETWORKID)" >> $@
	@echo "GOPATH=$(GOPATH)" >> $@

.PHONY: up down persistent
up: .env artifacts/orderer0.genesis.block
	docker-compose up -d && docker-compose logs -f
down:
	docker-compose down

persistent: genesis
	COMPOSE_FILE=docker-compose.yaml:docker-compose-persistent.yaml docker-compose up -d && docker-compose logs -f

# jinja2 rule
%.yaml: templates/%.yaml.in $(MAKEFILES) tools/jinja2-cli.py
	ORG=$(ORG) CONSORTIUM=$(CONSORTIUM) DOMAIN=$(DOMAIN) tools/jinja2-cli.py < $< > $@ || (rm -f $@; false)

.PHONY: clean distclean
clean:
	rm -rf artifacts crypto-config
	rm -f configtx.yaml crypto-config.yaml .env

distclean: clean
	rm -rf __pycache__
	rm -rf data
	rm -rf tools/*/*

.PHONY: FORCE
