# Variables
VERSION ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo 'dev')
REGISTRY ?= localhost:5000
FRONTEND_DIR := ./src/frontend
BACKEND_DIR := ./src/backend
FRONTEND_IMAGE := $(REGISTRY)/python-guestbook-frontend:$(VERSION)
BACKEND_IMAGE := $(REGISTRY)/python-guestbook-backend:$(VERSION)

# Namespaces
MONGO_NAMESPACE := mongodb
FRONTEND_NAMESPACE := guestbook-frontend
BACKEND_NAMESPACE := guestbook-backend
MONITORING_NAMESPACE := monitoring

# Chart locations
FRONTEND_CHART := ./charts/guestbook-frontend
BACKEND_CHART := ./charts/guestbook-backend
MONGO_CHART := ./charts/mongodb
MONITORING_CHART := ./charts/kube-prometheus-stack

# Release names
FRONTEND_RELEASE := guestbook-frontend
BACKEND_RELEASE := guestbook-backend
MONGO_RELEASE := guestbook-mongodb

# MongoDB secrets and configuration
MONGODB_SECRET_NAME := guestbook-mongodb
MONGODB_HOST := $(MONGO_RELEASE).$(MONGO_NAMESPACE).svc.cluster.local
MONGODB_PORT := 27017

# Helm timeout
HELM_TIMEOUT := 5m

.PHONY: all build push deploy delete create-secrets delete-secrets help

all: verify-variables build push deploy

build: build-frontend build-backend

build-frontend:
	docker build -t $(FRONTEND_IMAGE) ./$(FRONTEND_DIR)

build-backend:
	docker build -t $(BACKEND_IMAGE) ./$(BACKEND_DIR)

push: push-frontend push-backend

push-frontend:
	docker push $(FRONTEND_IMAGE)

push-backend:
	docker push $(BACKEND_IMAGE)

# deploy: Deploys the complete application stack including MongoDB, backend, frontend, and monitoring
deploy: check-prerequisites create-namespaces deploy-monitoring-stack deploy-frontend

# Checking for required tools
check-prerequisites:
	@which kubectl > /dev/null || (echo "kubectl is required but not installed" && exit 1)
	@which helm > /dev/null || (echo "helm is required but not installed" && exit 1)
	@which docker > /dev/null || (echo "docker is required but not installed" && exit 1)

# Add new target to create all namespaces upfront
create-namespaces:
	kubectl create namespace $(FRONTEND_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace $(BACKEND_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace $(MONGO_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace $(MONITORING_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -

deploy-mongo: create-namespaces
	helm upgrade --install $(MONGO_RELEASE) groundhog2k/mongodb \
	-f $(MONGO_CHART)/values.yaml -n $(MONGO_NAMESPACE) --create-namespace \
	--wait --timeout $(HELM_TIMEOUT)

create-mongodb-secrets: create-namespaces deploy-mongo
	# Get USERDB_PASSWORD from existing MongoDB secret
	$(eval MONGODB_USERDB_PASS := $(shell kubectl get secret -n $(MONGO_NAMESPACE) $(MONGODB_SECRET_NAME) -o jsonpath='{.data.USERDB_PASSWORD}' | base64 -d))

	kubectl create secret generic $(MONGODB_SECRET_NAME)-userdb \
		--from-literal=USERDB_PASSWORD='$(MONGODB_USERDB_PASS)' \
		--namespace $(BACKEND_NAMESPACE) \
		--dry-run=client -o yaml | kubectl apply -f -

	# Get root credentials for MongoDB URI
	$(eval MONGODB_ROOT_USER := $(shell kubectl get secret -n $(MONGO_NAMESPACE) $(MONGO_RELEASE) -o jsonpath='{.data.MONGO_INITDB_ROOT_USERNAME}' | base64 -d))
	$(eval MONGODB_ROOT_PASS := $(shell kubectl get secret -n $(MONGO_NAMESPACE) $(MONGO_RELEASE) -o jsonpath='{.data.MONGO_INITDB_ROOT_PASSWORD}' | base64 -d))
	
	kubectl create secret generic guestbook-mongodb-uri \
		--from-literal=mongodb-uri="mongodb://$(MONGODB_ROOT_USER):$(MONGODB_ROOT_PASS)@$(MONGODB_HOST):$(MONGODB_PORT)" \
		--namespace $(MONGO_NAMESPACE) \
		--dry-run=client -o yaml | kubectl apply -f -

deploy-backend: create-namespaces create-mongodb-secrets deploy-mongo
	helm upgrade --install $(BACKEND_RELEASE) ./$(BACKEND_CHART) \
	--set image.tag=$(VERSION) \
	-f $(BACKEND_CHART)/values.yaml -n $(BACKEND_NAMESPACE) --create-namespace \
	--wait --timeout $(HELM_TIMEOUT)

deploy-frontend: create-namespaces deploy-backend deploy-mongodb-exporter
	helm upgrade --install $(FRONTEND_RELEASE) ./${FRONTEND_CHART} \
	--set image.tag=$(VERSION) \
	-f $(FRONTEND_CHART)/values.yaml -n $(FRONTEND_NAMESPACE) \
	--wait --timeout $(HELM_TIMEOUT)

deploy-mongodb-exporter: create-namespaces deploy-mongo
	helm upgrade --install mongodb-exporter prometheus-community/prometheus-mongodb-exporter \
	-f $(MONGO_CHART)/mongodb-exporter.yaml -n $(MONGO_NAMESPACE) \
	--wait --timeout $(HELM_TIMEOUT)

deploy-monitoring-stack: create-namespaces
	helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
	-f $(MONITORING_CHART)/values.yaml -n $(MONITORING_NAMESPACE) \
	--wait --timeout $(HELM_TIMEOUT)

delete: delete-monitoring delete-apps delete-secrets delete-namespaces

delete-monitoring:
	helm uninstall mongodb-exporter -n $(MONGO_NAMESPACE) --wait || true
	helm uninstall kube-prometheus-stack -n $(MONITORING_NAMESPACE) --wait || true

delete-apps:
	helm uninstall $(FRONTEND_RELEASE) -n $(FRONTEND_NAMESPACE) --wait || true
	helm uninstall $(BACKEND_RELEASE) -n $(BACKEND_NAMESPACE) --wait || true
	helm uninstall $(MONGO_RELEASE) -n $(MONGO_NAMESPACE) --wait || true

delete-secrets:
	kubectl delete secret $(MONGODB_SECRET_NAME) --namespace $(BACKEND_NAMESPACE) --ignore-not-found

delete-namespaces:
	for ns in $(FRONTEND_NAMESPACE) $(BACKEND_NAMESPACE) $(MONGO_NAMESPACE) $(MONITORING_NAMESPACE); do \
		kubectl delete namespace $$ns --wait=true --timeout=$(HELM_TIMEOUT) --ignore-not-found; \
	done

help: ## Display this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "  %-20s %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

verify-variables:
	@test -n "$(REGISTRY)" || (echo "REGISTRY is not set" && exit 1)
	@test -n "$(VERSION)" || (echo "VERSION is not set" && exit 1)
