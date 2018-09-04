include config.env

UNAME:=$(shell uname -s)
ARCH:=$(shell arch)

BINDIR=bin/$(UNAME)-$(ARCH)

CRYPTO_DIR:=crypto-config/peerOrganizations/org1.hf.$(DOMAIN)

.PHONY: all
all: tools crypto-config genesis channel anchors .env

.PHONY: tools
tools: tools/.stamp

tools/.stamp: tools/hyperledger-fabric-linux-amd64-1.0.5/README tools/hyperledger-fabric-darwin-amd64-1.0.5/README
	@rm -f tools/.stamp
	curl -s $(shell cat tools/hyperledger-fabric-linux-amd64-1.0.5/README) | tar xvz -C tools/hyperledger-fabric-linux-amd64-1.0.5
	curl -s $(shell cat tools/hyperledger-fabric-darwin-amd64-1.0.5/README) | tar xvz -C tools/hyperledger-fabric-darwin-amd64-1.0.5
	@touch tools/.stamp

.PHONY: crypto-config
crypto-config: $(CRYPTO_DIR)/ca/current_sk

$(CRYPTO_DIR)/ca/current_sk: Makefile config.env crypto-config.yaml
	@mkdir -p crypto-config
	@rm -f $@
	$(BINDIR)/cryptogen generate --config=./crypto-config.yaml
	LATEST=$$(ls -1t $(CRYPTO_DIR)/ca/*_sk | head -1); ln -sf $$(basename $$LATEST) $@

.PHONY: genesis
genesis: artifacts/orderer.genesis.block

artifacts/orderer.genesis.block: Makefile config.env configtx.yaml
	@mkdir -p artifacts
	@rm -f $@
	FABRIC_CFG_PATH=$(PWD) $(BINDIR)/configtxgen -profile $(PROFILE) -outputBlock $@

.PHONY: channel
channel: artifacts/$(CHANNEL).channel.tx

artifacts/$(CHANNEL).channel.tx: Makefile config.env configtx.yaml
	@mkdir -p artifacts
	@rm -f $@
	FABRIC_CFG_PATH=$(PWD) $(BINDIR)/configtxgen -profile $(PROFILE) -outputCreateChannelTx $@ -channelID $(CHANNEL)

.PHONY: anchors
anchors: artifacts/$(CHANNEL).anchors.tx

artifacts/$(CHANNEL).anchors.tx: Makefile config.env configtx.yaml
	FABRIC_CFG_PATH=$(PWD) $(BINDIR)/configtxgen -profile $(PROFILE) -outputAnchorPeersUpdate $@ -channelID $(CHANNEL) -asOrg $(ORG)Organization1

# .env file for docker-compose
.env: Makefile config.env
	@echo "PROFILE=$(PROFILE)" > $@
	@echo "DOMAIN=$(DOMAIN)" >> $@


# jinja2 rule
%.yaml: templates/%.yaml.in
	DOMAIN=$(DOMAIN) ORG=$(ORG) tools/jinja2-cli.py < $< > $@ || rm -f $@

.PHONY: clean
clean:
	rm -rf __pycache__
	rm -rf artifacts crypto-config
	rm -f configtx.yaml crypto-config.yaml .env
	rm -f tools/.stamp
	rm -rf tools/hyperledger-fabric-linux-amd64-1.0.5/bin
	rm -rf tools/hyperledger-fabric-darwin-amd64-1.0.5/bin

.PHONY: FORCE
