DRIVER_Darwin:=hyperkit
#DRIVER_Darwin:=vmwarefusion
DRIVER_Linux:=kvm2
DRIVER:=${DRIVER_$(shell uname -s)}

PIDFILE_hyperkit:=~/.minikube/machines/minikube/hyperkit.pid
PIDFILE_vmwarefusion:=~/.minikube/machines/minikube/minikube.vmdk.lck
PIDFILE_kvm2:=/var/run/libvirt/qemu/minikube.pid

PIDFILE:=${PIDFILE_${DRIVER}}

.PHONY: all clean
all:
	make -C ..

clean:
	make -C .. k8s_clean

.PHONY: apply delete-deps delete-services delete-pods
apply:
	@for i in *.yaml; do kubectl apply -f $$i; done

delete-deps:
	kubectl delete deployments --namespace hlf-service-network --all

delete-services:
	kubectl delete services --namespace hlf-service-network --all

delete-pods:
	kubectl delete pods --namespace hlf-service-network --all

.PHONY: start stop nuke
start:
	@if [ ! -e ${PIDFILE} ]; then minikube start --vm-driver=${DRIVER} --kubernetes-version=v1.13.1 --feature-gates='CoreDNS=true'; fi
	@./forwarding.sh start-proxy

stop:
	@./forwarding.sh stop
	@./forwarding.sh stop-proxy
	@if [ -e ${PIDFILE} ]; then minikube stop; fi

nuke:	stop
	minikube delete
	@rm -rf ${PIDFILE}

# vim: noexpandtab
