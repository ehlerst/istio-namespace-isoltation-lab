PROJECT_NAME?=istio-namespace-isolation-lab

KIND_VERSION?=v1.24.0
KIND_CLUSTER_NAME?=${PROJECT_NAME}-${KIND_VERSION}
KIND_CONTEXT?=kind-${KIND_CLUSTER_NAME}

install-prerequisites: 
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.18.2 TARGET_ARCH=x86_64 sh -

kind: kind-create

kind-create:
	kind create cluster --name ${KIND_CLUSTER_NAME} --image kindest/node:${KIND_VERSION} --name ${KIND_CLUSTER_NAME} --config kind/config.yaml

kind-context:
	kubectl config use ${KIND_CONTEXT}


istio-setup: kind-context
	istioctl operator init
	kubectl apply -f istio/base-setup/istio.yaml
	sleep 5
	kubectl wait --for jsonpath='.status.status'=HEALTHY istiooperator/istio -n istio-system --timeout=180s
	kubectl apply -f istio/base-setup/mtls.yaml

istio-extras: kind-context 
	kubectl apply -f istio/extras/prometheus.yaml
	kubectl apply -f istio/extras/kaili.yaml
	kubectl apply -f istio/extras/grafana.yaml
	kubectl apply -f istio/extras/loki.yaml
	kubectl apply -f istio/extras/jaeger.yaml
	kubectl apply -f istio/extras/otel.yaml
	kubectl apply -f istio/extras/telemetry.yaml
	istioctl install -f istio/extras/iops-loki.yaml -y

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
	kubectl -n isiost-system port-forward service/grafana 3000

loki-api: kind-context
	kubectl -n isiost-system port-forward service/loki 3100
	

logs: kind-context
	logcli query '{mesh="cluster.local"}'