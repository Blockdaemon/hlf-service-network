include config.env

# include overrides if the file exists
-include local.env

MAKEFILES:=Makefile config.env $(wildcard local.env)	# only care about local.env if it is there

UNAME:=$(shell uname -s)
ARCH:=$(shell arch)

TOOLDIR:=tools/$(shell readlink tools/$(UNAME)-$(ARCH))
TOOLURL:=$(TOOLDIR)/README
BINDIR:=$(TOOLDIR)/bin

CRYPTO_DIR:=crypto-config/peerOrganizations/org1.hf.$(DOMAIN)

.PHONY: all
all: crypto-config genesis channel anchors .env

$(BINDIR)/cryptogen $(BINDIR)/configtxgen: $(TOOLURL)
	curl -s $(shell cat $(TOOLURL)) | tar xvz -C $(TOOLDIR) || (rm -rf $(BINDIR); false)
	@touch $(BINDIR)/cryptogen $(BINDIR)/configtxgen	# tar will extract with the old date, which will be older than README

.PHONY: crypto-config
crypto-config: $(CRYPTO_DIR)/ca/current_sk

$(CRYPTO_DIR)/ca/current_sk: $(BINDIR)/cryptogen $(MAKEFILES) crypto-config.yaml
	@mkdir -p crypto-config
	@rm -f $@
	$(BINDIR)/cryptogen generate --config=./crypto-config.yaml
	LATEST=$$(ls -1t $(CRYPTO_DIR)/ca/*_sk | head -1); ln -sf $$(basename $$LATEST) $@

.PHONY: genesis
genesis: artifacts/orderer.genesis.block

artifacts/orderer.genesis.block: $(BINDIR)/configtxgen $(MAKEFILES) configtx.yaml
	@mkdir -p artifacts
	@rm -f $@
	FABRIC_CFG_PATH=$(PWD) $(BINDIR)/configtxgen -profile $(PROFILE) -outputBlock $@

.PHONY: channel
channel: artifacts/$(CHANNEL).channel.tx

artifacts/$(CHANNEL).channel.tx: $(BINDIR)/configtxgen $(MAKEFILES) configtx.yaml
	@mkdir -p artifacts
	@rm -f $@
	FABRIC_CFG_PATH=$(PWD) $(BINDIR)/configtxgen -profile $(PROFILE) -outputCreateChannelTx $@ -channelID $(CHANNEL)

.PHONY: anchors
anchors: artifacts/$(CHANNEL).anchors.tx

artifacts/$(CHANNEL).anchors.tx: $(BINDIR)/configtxgen $(MAKEFILES) configtx.yaml
	FABRIC_CFG_PATH=$(PWD) $(BINDIR)/configtxgen -profile $(PROFILE) -outputAnchorPeersUpdate $@ -channelID $(CHANNEL) -asOrg $(ORG)Organization1

# .env file for docker-compose
.env: $(MAKEFILES)
	@echo "PROFILE=$(PROFILE)" > $@
	@echo "DOMAIN=$(DOMAIN)" >> $@
	@echo "NETWORKID=$(NETWORKID)" >> $@

# jinja2 rule
%.yaml: templates/%.yaml.in
	ORG=$(ORG) CONSORTIUM=$(CONSORTIUM) DOMAIN=$(DOMAIN) tools/jinja2-cli.py < $< > $@ || (rm -f $@; false)

.PHONY: clean
clean:
	rm -rf __pycache__
	rm -rf artifacts crypto-config
	rm -f configtx.yaml crypto-config.yaml .env
	rm -rf tools/hyperledger-fabric-linux-amd64-1.0.5/bin
	rm -rf tools/hyperledger-fabric-darwin-amd64-1.0.5/bin

.PHONY: FORCE
