PROJECT_NAME?=istio-namespace-isolation-lab

KIND_VERSION?=v1.24.15
KIND_CLUSTER_NAME?=${PROJECT_NAME}-${KIND_VERSION}
KIND_CONTEXT?=kind-${KIND_CLUSTER_NAME}

install-prerequisites: 
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.19.0 TARGET_ARCH=x86_64 sh -
	export PATH=$PATH:/$(shell pwd)/istio-1.19.0/bin

kind: kind-create

kind-create:
	kind create cluster --name ${KIND_CLUSTER_NAME} --image kindest/node:${KIND_VERSION} --name ${KIND_CLUSTER_NAME} --config kind/config.yaml

kind-delete:
	kind delete cluster --name ${KIND_CLUSTER_NAME} --name ${KIND_CLUSTER_NAME} 


kind-context:
	kubectl config use ${KIND_CONTEXT}


istio-setup: kind-context
	-helm repo add istio https://istio-release.storage.googleapis.com/charts
	helm repo update
	-kubectl create ns istio-system
	helm upgrade -i istio-base istio/base -n istio-system -f istio/base-setup/values.yaml --set defaultRevision=default
	kubectl apply -f istio/base-setup/mtls.yaml
	helm upgrade -i istiod istio/istiod -n istio-system --wait -f istio/base-setup/values.yaml 

istio-extras: kind-context 
	kubectl apply -f istio/extras/prometheus.yaml
	kubectl apply -f istio/extras/kaili.yaml
	kubectl apply -f istio/extras/grafana.yaml
	kubectl apply -f istio/extras/loki.yaml
	kubectl apply -f istio/extras/jaeger.yaml
	kubectl apply -f istio/extras/otel.yaml
	kubectl apply -f istio/extras/telemetry.yaml
#	istioctl install -f istio/extras/iops-loki.yaml -y

istio-apps: kind-context
	-kubectl create ns reviews
	-kubectl label ns reviews istio-injection=enabled --overwrite
	-kubectl create ns ratings
	-kubectl label ns ratings istio-injection=enabled --overwrite
	-kubectl create ns details
	-kubectl label ns details istio-injection=enabled --overwrite
	-kubectl create ns productpage
	-kubectl label ns productpage istio-injection=enabled --overwrite
	kubectl apply -f istio/apps/bookinfo.yaml

istio-restart-apps: kind-context
	kubectl -n reviews rollout restart deployment
	kubectl -n ratings rollout restart deployment
	kubectl -n details rollout restart deployment
	kubectl -n productpage rollout restart deployment

bookinfo-productpage-test: kind-context

grafana-ui: kind-context
	kubectl -n istio-system port-forward service/grafana 3000

loki-api: kind-context
	kubectl -n istio-system port-forward service/loki 3100
	

logs: kind-context
	logcli query '{mesh="cluster.local"}'