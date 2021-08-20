.PHONY: help
.DEFAULT_GOAL := help

dev: ## Run API server for debug
	@python app.py

test: ## Test API
	@curl -X POST -H "Content-Type: application/json" -d @request.json http://localhost:8000/image-policy/base-image

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[38;2;98;209;150m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
