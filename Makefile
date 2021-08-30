.PHONY: help
.DEFAULT_GOAL := help

IMAGE_NAME := "imokuri123/image-policy-webhook-backend"
IMAGE_TAG := "latest"

setup: ## Create kind cluster
	@kind create cluster

teardown: ## Delete kind cluster
	@kind delete cluster

helm-repo: ## Setup helm helm-repo
	@helm repo add metallb https://metallb.github.io/metallb
	@helm repo add nginx-stable https://helm.nginx.com/stable
	@helm repo update

metallb: ## Install metallb
	@kubectl create namespace metallb-system
	@helm install metallb metallb/metallb -n metallb-system -f metallb-values.yaml

nginx: ## Install nginx
	@kubectl create namespace nginx-system
	@helm install nginx nginx-stable/nginx-ingress -n nginx-system
	@kubectl patch ingressclass nginx -p '{"metadata": {"annotations":{"ingressclass.kubernetes.io/is-default-class":"true"}}}'

dev: ## Run API server for debug
	@python app.py

test: ## Test API (Passed)
	@curl -X POST -H "Content-Type: application/json" -d @request_good.json \
		http://localhost:8000/image-policy/base-image

test-fail: ## Test API (Failed)
	@curl -X POST -H "Content-Type: application/json" -d @request_bad.json \
		http://localhost:8000/image-policy/base-image

svc_ip = $(shell kubectl get service -n image-policy image-policy-svc -o json | jq -r '.status.loadBalancer.ingress[0].ip')
test-service: ## Test API (Kubernetes Service)
	@curl -X POST -H "Content-Type: application/json" -d @request_good.json \
		--key /certs/apiserver.key --cert /certs/apiserver.crt \
		https://ic.lab.imokuri123.com/image-policy/base-image

test-service-fail: ## Test API (Kubernetes Service)
	@curl -X POST -H "Content-Type: application/json" -d @request_bad.json \
		--key /certs/apiserver.key --cert /certs/apiserver.crt \
		https://ic.lab.imokuri123.com/image-policy/base-image

build: ## Build docker image
	@docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

push: ## Push docker image to DockerHub
	@docker push $(IMAGE_NAME):$(IMAGE_TAG)

run: ## Run docker container
	@docker run -dt -p 10443:10443 $(IMAGE_NAME):$(IMAGE_TAG)

secret: ## Create secret
	@sed "s/SERVER_CRT/$(shell cat image-policy.crt | base64 -w0)/g" secret.yaml | \
		sed "s/SERVER_KEY/$(shell cat image-policy.key | base64 -w0)/g" | \
		kubectl apply -f -

up-certs: ## Upload certificates
	@docker exec kind-control-plane mkdir -p /etc/kubernetes/admission-control
	@docker cp ./admission-configuration.yaml kind-control-plane:/etc/kubernetes/admission-control/
	@docker cp ./image-policy-webhook.conf kind-control-plane:/etc/kubernetes/admission-control/
	@docker cp ./image-policy-webhook.json kind-control-plane:/etc/kubernetes/admission-control/
	@docker exec kind-control-plane chown root:root /etc/kubernetes/admission-control/admission-configuration.yaml
	@docker exec kind-control-plane chown root:root /etc/kubernetes/admission-control/image-policy-webhook.conf
	@docker exec kind-control-plane chown root:root /etc/kubernetes/admission-control/image-policy-webhook.json
	@docker cp ./image-policy.crt kind-control-plane:/etc/kubernetes/pki/
	@docker cp ./image-policy.key kind-control-plane:/etc/kubernetes/pki/
	@docker exec kind-control-plane chown root:root /etc/kubernetes/pki/image-policy.crt
	@docker exec kind-control-plane chown root:root /etc/kubernetes/pki/image-policy.key

get-certs:  ## Download certificates
	@docker cp kind-control-plane:/etc/kubernetes/pki/apiserver.crt .
	@docker cp kind-control-plane:/etc/kubernetes/pki/apiserver.key .
	@sudo mv apiserver.crt apiserver.key /certs/

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[38;2;98;209;150m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
