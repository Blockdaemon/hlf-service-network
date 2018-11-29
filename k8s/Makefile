.PHONY: all
all:
	make -C ..

.PHONY: init apply delete-all
init:
	@for i in init.d/*.sh; do ./$$i; done

apply:
	@for i in *.yaml; do kubectl apply -f $$i; done

delete-deps:
	kubectl get deployments -o name | xargs kubectl delete

delete-pods:
	kubectl get pods -o name | xargs kubectl delete
