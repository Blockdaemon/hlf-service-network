include config.mk

# include overrides if the file exists
-include local.mk

ifndef GOPATH
    GOPATH:=$(HOME)/go
    export GOPATH
endif

export FABRIC_CFG_PATH:=$(shell pwd)

# If any of MKFILES changes, redo everything
# Note that Makefile isn't in this list, or everytime we touch Makefile, it
# would regenerate everything
MKFILES:=config.mk $(wildcard local.mk)	# only care about local.mk if it is there
UNAME:=$(shell uname -s)
ARCH:=$(shell arch)

ARCHURL_Darwin-i386:=darwin-amd64
ARCHURL_Linux-x86_64:=linux-amd64
ARCHURL_CYGWIN_NT-10.0-x86_64:=windows-amd64
URLPATH:=$(ARCHURL_$(UNAME)-$(ARCH))
ifndef URLPATH
$(error Do not know how to handle $(UNAME)-$(ARCH))
endif
TOOLURL:=https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/$(URLPATH)-$(HLF_VERSION)/hyperledger-fabric-$(URLPATH)-$(HLF_VERSION).tar.gz

TOOLDIR:=tools/$(UNAME)-$(ARCH)/$(HLF_VERSION)
BINDIR:=$(TOOLDIR)/bin

CRYPTO_DIR:=crypto-config/peerOrganizations/$(SUBDOMAIN1).$(DOMAIN)
CURRENT_SK:=$(CRYPTO_DIR)/ca/current_sk
MSP_CA_PEM:=$(CRYPTO_DIR)/msp/cacerts/ca.$(SUBDOMAIN1).$(DOMAIN)-cert.pem
MSP_ADMIN_PEM:=$(CRYPTO_DIR)/msp/admincerts/Admin@$(SUBDOMAIN1).$(DOMAIN)-cert.pem

.PHONY: all
all: genesis channel anchor-peers .secrets

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

genesis: artifacts/orderer0.genesis.block
artifacts/orderer0.genesis.block: $(BINDIR)/configtxgen configtx.yaml $(CRYPTO_DIR)/ca/current_sk
	@mkdir -p artifacts
	@# 1.2.0 requires -channelID for genesis block, but this breaks 1.1.0
	$(BINDIR)/configtxgen -profile $(PROFILE)Solo -outputBlock $@ -channelID genesis-channel

channel: artifacts/$(CHANNEL).channel.tx
artifacts/$(CHANNEL).channel.tx: $(BINDIR)/configtxgen configtx.yaml $(MSP_CA_PEM) $(MSP_ADMIN_PEM)
	@mkdir -p artifacts
	$(BINDIR)/configtxgen -profile $(PROFILE)Channel -outputCreateChannelTx $@ -channelID $(CHANNEL)

anchor-peers: artifacts/$(CHANNEL).anchor-peers.tx
artifacts/$(CHANNEL).anchor-peers.tx: $(BINDIR)/configtxgen configtx.yaml
	@mkdir -p artifacts
	$(BINDIR)/configtxgen -profile $(PROFILE)Channel -outputAnchorPeersUpdate $@ -channelID $(CHANNEL) -asOrg $(SUBORG1NAME)

# .env file for docker-compose
.env: $(MKFILES)
	@echo "HLF_ARCH=$(HLF_ARCH)" > $@
	@echo "HLF_VERSION=$(HLF_VERSION)" >> $@
	@echo "PROFILE=$(PROFILE)" >> $@
	@echo "CONSORTIUM=$(CONSORTIUM)" >> $@
	@echo "ORGNAME=$(ORGNAME)" >> $@
	@echo "SUBORG1NAME=$(SUBORG1NAME)" >> $@
	@echo "SUBORG2NAME=$(SUBORG2NAME)" >> $@
	@echo "DOMAIN=$(DOMAIN)" >> $@
	@echo "SUBDOMAIN1=$(SUBDOMAIN1)" >> $@
	@echo "SUBDOMAIN2=$(SUBDOMAIN2)" >> $@
	@echo "NETWORKID=$(NETWORKID)" >> $@
	@echo "GOPATH=$(GOPATH)" >> $@

.secrets:
	tools/gensecrets

.PHONY: up down persistent
docker-compose.yaml: .env

up: docker-compose.yaml artifacts/orderer0.genesis.block
	docker-compose up -d && docker-compose logs -f
down: docker-compose.yaml
	docker-compose down

persistent: .env artifacts/orderer0.genesis.block
	COMPOSE_FILE=docker-compose.yaml:docker-compose-persistent.yaml docker-compose up -d && docker-compose logs -f

TEMPLATES = $(wildcard templates/*.in)

.PHONY: clean distclean
clean:
	rm -rf artifacts crypto-config
	rm -f configtx.yaml crypto-config.yaml .env .secrets

distclean: clean
	rm -rf __pycache__
	rm -rf data
	rm -rf tools/*/*
env:
	@echo GENFILES=\"$(GENFILES)\"

.PHONY: FORCE

include k8s/k8s.mk
include rules.mk
