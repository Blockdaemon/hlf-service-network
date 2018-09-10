include config.env

# include overrides if the file exists
-include local.env

ifndef GOPATH
    GOPATH:=$(HOME)/go
    export GOPATH
endif

MAKEFILES:=Makefile config.env $(wildcard local.env)	# only care about local.env if it is there

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
ifndef URLPATH
# Prevent really bad things on rm -rf $(BINDIR)
$(error TOOLDIR is empty!)
endif
BINDIR:=$(TOOLDIR)/bin

CRYPTO_DIR:=crypto-config/peerOrganizations/org1.hf.$(DOMAIN)

.PHONY: all
all: crypto-config genesis channel anchors .env

$(BINDIR)/cryptogen $(BINDIR)/configtxgen: # $(MAKEFILES)
	mkdir -p $(TOOLDIR)
	curl -s $(TOOLURL) | tar xvz -C $(TOOLDIR) || (rm -rf $(BINDIR); false)
	@touch $(BINDIR)/cryptogen $(BINDIR)/configtxgen	# tar will extract with the old date, which will be older than README

.PHONY: crypto-config genesis channel anchors
crypto-config: $(CRYPTO_DIR)/ca/current_sk

$(CRYPTO_DIR)/ca/current_sk: $(BINDIR)/cryptogen $(MAKEFILES) crypto-config.yaml
	@mkdir -p crypto-config
	@rm -f $@
	$(BINDIR)/cryptogen generate --config=./crypto-config.yaml
	LATEST=$$(ls -1t $(CRYPTO_DIR)/ca/*_sk | head -1); mv $$LATEST $@

genesis: artifacts/orderer.genesis.block

artifacts/orderer.genesis.block: $(BINDIR)/configtxgen $(MAKEFILES) configtx.yaml
	@mkdir -p artifacts
	@rm -f $@
	@# FIXME - 1.2.0 requires -channelID, but this breaks 1.1.0
	FABRIC_CFG_PATH=$(PWD) $(BINDIR)/configtxgen -profile $(PROFILE) -outputBlock $@ # -channelID $(CHANNEL)

channel: artifacts/$(CHANNEL).channel.tx

artifacts/$(CHANNEL).channel.tx: $(BINDIR)/configtxgen $(MAKEFILES) configtx.yaml
	@mkdir -p artifacts
	@rm -f $@
	FABRIC_CFG_PATH=$(PWD) $(BINDIR)/configtxgen -profile $(PROFILE) -outputCreateChannelTx $@ -channelID $(CHANNEL)

anchors: artifacts/$(CHANNEL).anchors.tx

artifacts/$(CHANNEL).anchors.tx: $(BINDIR)/configtxgen $(MAKEFILES) configtx.yaml
	FABRIC_CFG_PATH=$(PWD) $(BINDIR)/configtxgen -profile $(PROFILE) -outputAnchorPeersUpdate $@ -channelID $(CHANNEL) -asOrg $(ORG)Organization1

# .env file for docker-compose
.env: $(MAKEFILES)
	@echo "HLF_ARCH=$(HLF_ARCH)" > $@
	@echo "HLF_VERSION=$(HLF_VERSION)" >> $@
	@echo "PROFILE=$(PROFILE)" >> $@
	@echo "DOMAIN=$(DOMAIN)" >> $@
	@echo "NETWORKID=$(NETWORKID)" >> $@
	@echo "GOPATH=$(GOPATH)" >> $@

.PHONY: up down persistent
up: all
	docker-compose up
down:
	docker-compose down

persistent: all
	COMPOSE_FILE=docker-compose.yaml:docker-compose-persistent.yaml docker-compose up

# jinja2 rule
%.yaml: templates/%.yaml.in
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
