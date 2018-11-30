TEMPLATES += $(wildcard templates/k8s/*.in)

all: k8s_all
clean: k8s_clean

.PHONY: k8s_all k8s_clean

k8s/peers.yaml: templates/k8s/peer-env.yaml

k8s_clean:
	rm -f k8s/ca-deployment.yaml k8s/orderer.yaml k8s/peers.yaml
