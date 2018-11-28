TEMPLATES += $(wildcard templates/k8s/*.in)

all: k8s_all

.PHONY: k8s_all

k8s_all: k8s/ca-deployment.yaml
