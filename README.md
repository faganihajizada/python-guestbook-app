# guestbook-service

The Guestbook sample from https://github.com/GoogleCloudPlatform/cloud-code-samples/tree/v1/python/python-guestbook

Details of the challenge: [instructions.md](instructions.md)

## Features

- Python Flask frontend and backend services
- MongoDB database
- Kubernetes-native deployment using Helm charts
- Monitoring with Prometheus and Grafana
- Support for automated scaling with HorizontalPodAutoscaler
- Pod disruption budgets for high availability
- Ingress configuration for external access

## Prerequisites

- [Docker](https://docs.docker.com/)
- Kubernetes cluster (local using [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)). A [script](./start-local.sh) can be used to start a local kind cluster and image registry
- [Helm](https://helm.sh/docs/intro/install/)
- kubectl

## Quick Start

1. Run provided [Makefile](./Makefile):

```console
make all
```

3. View available commands:

```console
make help
Python Guestbook Application Management
======================================

Available commands:

  Command              Description
  all                   Set up cluster and deploy complete application
  deploy                Deploy to existing cluster without setup
  build                 Build all Docker images
  build-frontend        Build the frontend Docker image
  build-backend         Build the backend Docker image
  push                  Push all Docker images
  push-frontend         Push the frontend Docker image
  push-backend          Push the backend Docker image
  delete                Remove all application resources
  show-access           Display access URLs and credentials
  help                  Display available commands with descriptions
  verify-variables      Verify required variables are set
  setup-local-cluster   Setup local Kind cluster with registry and ingress
  delete-all            Delete Kind cluster
  verify-registry       Verify registry is accessible

Examples:
  make setup-local-cluster   # Set up a local Kind cluster with registry and ingress
  make all                   # Set up cluster and deploy complete application
  make deploy                # Deploy to existing cluster without cluster setup
  make delete                # Clean up all resources
  make delete-all            # Clean up all resources and delete Kind cluster

Configuration:
  REGISTRY = localhost:5000
  VERSION = [VERSION]
```

## Access the services

- Frontend: http://frontend.localhost
- Grafana: http://grafana.localhost
- Prometheus: http://prometheus.localhost 
- Alertmanager: http://alertmanager.localhost

Note: The above URLs assume you are using the default ingress configuration with a local kind cluster. Update the `hostnames` in the respective Helm values files if using a different domain.

## Architecture Diagram

![Architecture Diagram](./docs/architecture-diagram.png)

## Helm Chart Structure

```
├── charts
│   ├── guestbook-backend
│   │   ├── Chart.yaml
│   │   ├── README.md
│   │   ├── README.md.gotmpl
│   │   ├── dashboards
│   │   │   └── guestbook-backend.json
│   │   ├── templates
│   │   │   ├── NOTES.txt
│   │   │   ├── _helpers.tpl
│   │   │   ├── configmap.yaml
│   │   │   ├── deployment.yaml
│   │   │   ├── grafana-dashboards.yaml
│   │   │   ├── hpa.yaml
│   │   │   ├── pdb.yaml
│   │   │   ├── prometheus-rules.yaml
│   │   │   ├── secret.yaml
│   │   │   ├── service.yaml
│   │   │   ├── serviceaccount.yaml
│   │   │   └── servicemonitor.yaml
│   │   └── values.yaml
│   ├── guestbook-frontend
│   │   ├── Chart.yaml
│   │   ├── README.md
│   │   ├── README.md.gotmpl
│   │   ├── dashboards
│   │   │   └── guestbook-frontend.json
│   │   ├── templates
│   │   │   ├── NOTES.txt
│   │   │   ├── _helpers.tpl
│   │   │   ├── deployment.yaml
│   │   │   ├── grafana-dashboard.yaml
│   │   │   ├── hpa.yaml
│   │   │   ├── ingress.yaml
│   │   │   ├── pdb.yaml
│   │   │   ├── prometheus-rules.yaml
│   │   │   ├── service.yaml
│   │   │   ├── serviceaccount.yaml
│   │   │   └── servicemonitor.yaml
│   │   └── values.yaml
│   ├── kube-prometheus-stack
│   │   ├── README.md
│   │   └── values.yaml
│   └── mongodb
│       ├── README.md
│       ├── mongodb-exporter.yaml
│       └── values.yaml
```

Each Helm Chart folder includes a README.md file that provides detailed information about the chart.

- [guestbook-backend](./charts/guestbook-backend/)
- [guestbook-frontend](./charts/guestbook-frontend/)
- [MongoDB](./charts/mongodb/)
- [Kube-Prometheus-Stack](./charts/kube-prometheus-stack/)

## Configuration

Each component can be configured via their respective `values.yaml` files. See individual chart READMEs for detailed configuration options.

## Testing Scaling and Alerts

The examples below are for guestbook-frontend. Please adjust the name of the service and namespace accordingly if needed.

### Scale Down Test

1. Scale down the frontend deployment:

```console
kubectl scale deployment guestbook-frontend --replicas=1 -n guestbook-frontend
```

2. Check the HorizontalPodAutoscaler status:

```console
kubectl get hpa guestbook-frontend -n guestbook-frontend
```

3. Monitor pod status:

```console
kubectl get pods -n guestbook-frontend -l tier=frontend
```

### Checking Prometheus Alerts

1. Scale down the frontend deployment:

```console
kubectl scale deployment guestbook-frontend --replicas=0 -n guestbook-frontend
```

2. Look for the following alerts:

   - `GuestbookFrontendNoPods`: Triggers when frontend pods are not available

3. To resolve the alerts, scale the deployment back up:

```console
kubectl scale deployment guestbook-frontend --replicas=2 -n default
```
