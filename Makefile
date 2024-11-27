# Variables
GIT_VERSION := $(shell git rev-parse --short HEAD 2>/dev/null || echo 'latest')
VERSION ?= latest
VERSIONS := $(if $(GIT_VERSION),$(GIT_VERSION) latest,latest)

LOCAL_REGISTRY ?= localhost:5000
FRONTEND_DIR := ./src/frontend
BACKEND_DIR := ./src/backend

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

# Helm Release names
FRONTEND_RELEASE := guestbook-frontend
BACKEND_RELEASE := guestbook-backend
MONGO_RELEASE := guestbook-mongodb
MONGO_EXPORTER_RELEASE := mongodb-exporter
PROMETHEUS_STACK_RELEASE := kube-prometheus-stack

# MongoDB secrets and configuration
MONGODB_SECRET_NAME := guestbook-mongodb
MONGODB_HOST := $(MONGO_RELEASE).$(MONGO_NAMESPACE).svc.cluster.local
MONGODB_PORT := 27017

# Helm timeout
HELM_TIMEOUT := 5m

# Add new variable for script location
LOCAL_SETUP_SCRIPT := ./start-local.sh

.PHONY: deploy build push delete create-secrets delete-secrets help setup-local-cluster delete-all

# Set up cluster and deploy complete application
all: check-prerequisites verify-variables setup-local-cluster verify-registry deploy

# Deploy to existing cluster without setup
deploy: check-prerequisites verify-variables verify-registry build push create-namespaces deploy-monitoring-stack deploy-mongo deploy-backend deploy-frontend show-access

build: build-frontend build-backend  ## Build all Docker images

build-frontend:  ## Build the frontend Docker image
	@echo "Building frontend images"
	@for ver in $(VERSIONS); do \
		echo "Building: $(LOCAL_REGISTRY)/python-guestbook-frontend:$$ver"; \
		docker build -t $(LOCAL_REGISTRY)/python-guestbook-frontend:$$ver ./$(FRONTEND_DIR) || (echo "Frontend build failed" && exit 1); \
	done

build-backend: ## Build the backend Docker image
	@echo "Building backend images"
	@for ver in $(VERSIONS); do \
		echo "Building: $(LOCAL_REGISTRY)/python-guestbook-backend:$$ver"; \
		docker build -t $(LOCAL_REGISTRY)/python-guestbook-backend:$$ver ./$(BACKEND_DIR) || (echo "Backend build failed" && exit 1); \
	done

push: push-frontend push-backend  ## Push all Docker images

push-frontend: ## Push the frontend Docker image
	@for ver in $(VERSIONS); do \
		echo "Pushing to $(LOCAL_REGISTRY)/python-guestbook-frontend:$$ver"; \
		docker push $(LOCAL_REGISTRY)/python-guestbook-frontend:$$ver || exit 1; \
	done

push-backend: ## Push the backend Docker image
	@for ver in $(VERSIONS); do \
		echo "Pushing to $(LOCAL_REGISTRY)/python-guestbook-backend:$$ver"; \
		docker push $(LOCAL_REGISTRY)/python-guestbook-backend:$$ver || exit 1; \
	done

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
	helm repo add groundhog2k https://groundhog2k.github.io/helm-charts/
	helm repo update
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
	-f $(BACKEND_CHART)/values.yaml -n $(BACKEND_NAMESPACE) --create-namespace \
	--wait --timeout $(HELM_TIMEOUT)

deploy-frontend: create-namespaces deploy-backend deploy-mongodb-exporter
	helm upgrade --install $(FRONTEND_RELEASE) ./${FRONTEND_CHART} \
	-f $(FRONTEND_CHART)/values.yaml -n $(FRONTEND_NAMESPACE) \
	--wait --timeout $(HELM_TIMEOUT)

deploy-mongodb-exporter: create-namespaces deploy-mongo
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm upgrade --install ${MONGO_EXPORTER_RELEASE} prometheus-community/prometheus-mongodb-exporter \
	-f $(MONGO_CHART)/mongodb-exporter.yaml -n $(MONGO_NAMESPACE) \
	--wait --timeout $(HELM_TIMEOUT)

deploy-monitoring-stack: create-namespaces
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm upgrade --install ${PROMETHEUS_STACK_RELEASE} prometheus-community/kube-prometheus-stack \
	-f $(MONITORING_CHART)/values.yaml -n $(MONITORING_NAMESPACE) \
	--wait --timeout $(HELM_TIMEOUT)

delete: delete-monitoring delete-apps delete-secrets delete-namespaces  ## Remove all application resources

delete-monitoring:
	helm uninstall ${MONGO_EXPORTER_RELEASE} -n $(MONGO_NAMESPACE) --wait || true
	helm uninstall ${PROMETHEUS_STACK_RELEASE} -n $(MONITORING_NAMESPACE) --wait || true

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

show-access: ## Display access URLs and credentials
	@echo "\nAccess URLs:"
	@echo "  Frontend: http://frontend.localhost"
	@echo "  Grafana: http://grafana.localhost"
	@echo "  Prometheus: http://prometheus.localhost"
	@echo "  Alertmanager: http://alertmanager.localhost"
	@echo "\nGrafana Credentials:"
	@echo "  Username: admin"
	@echo "  Password: $$(kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d)"

help:  ## Display available commands with descriptions
	@echo "Python Guestbook Application Management"
	@echo "======================================"
	@echo ""
	@echo "Available commands:"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "  \033[36m%-20s\033[0m %s\n", "Command", "Description"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make setup-local-cluster   # Set up a local Kind cluster with registry and ingress"
	@echo "  make all                   # Set up cluster and deploy complete application"
	@echo "  make deploy                # Deploy to existing cluster without cluster setup"
	@echo "  make delete                # Clean up all resources"
	@echo "  make delete-all            # Clean up all resources and delete Kind cluster"
	@echo ""
	@echo "Configuration:"
	@echo "  LOCAL_REGISTRY = $(LOCAL_REGISTRY)"
	@echo "  VERSION = $(VERSION)"

verify-variables:  ## Verify required variables are set
	@test -n "$(LOCAL_REGISTRY)" || (echo "LOCAL_REGISTRY is not set" && exit 1)
	@test -n "$(VERSION)" || (echo "VERSION is not set, using 'latest'" && VERSION=latest)
	@echo "Building with VERSION=$(VERSION)"
	@echo "Using LOCAL_REGISTRY=$(LOCAL_REGISTRY)"

setup-local-cluster: ## Setup local Kind cluster with registry and ingress
	@echo "Setting up local Kind cluster..."
	@chmod +x $(LOCAL_SETUP_SCRIPT)
	@$(LOCAL_SETUP_SCRIPT)
	@echo "Waiting 60 seconds for cluster initialization..."
	@sleep 60
	@echo "Waiting for ingress-nginx to be ready..."
	@kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=90s
	@echo "Waiting for admission patch job..."
	@kubectl wait --namespace ingress-nginx \
		--for=condition=complete job/ingress-nginx-admission-patch \
		--timeout=90s

# Complete cleanup including Kind cluster
delete-all: delete  ## Delete Kind cluster
	@echo "Deleting Kind cluster..."
	@kind delete cluster || echo "No Kind cluster found or error deleting cluster"

verify-registry:  ## Verify registry is accessible
	@echo "Verifying registry accessibility..."
	@docker ps > /dev/null 2>&1 || (echo "Docker is not running" && exit 1)
	@curl -s http://$(LOCAL_REGISTRY)/v2/_catalog > /dev/null || (echo "Registry is not accessible" && exit 1)
	@echo "Registry verified successfully"
