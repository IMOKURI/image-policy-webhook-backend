.PHONY: help
.DEFAULT_GOAL := help

IMAGE_NAME := "imokuri123/image-policy-webhook-backend"
IMAGE_TAG := "latest"

dev: ## Run API server for debug
	@python app.py

test: ## Test API
	@curl -X POST -H "Content-Type: application/json" -d @request.json http://localhost:8000/image-policy/base-image

test-ssl: ## Test API (SSL)
	@curl -k -X POST -H "Content-Type: application/json" -d @request.json https://localhost/image-policy/base-image

build: ## Build docker image
	@docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

push: ## Push docker image to DockerHub
	@docker push $(IMAGE_NAME):$(IMAGE_TAG)

run: ## Run docker container
	@docker run -dt -p 8000:8000 $(IMAGE_NAME):$(IMAGE_TAG)

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[38;2;98;209;150m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
