# MongoDB Helm Chart

This is a configuration values file for the [groundhog2k/mongodb](https://github.com/groundhog2k/helm-charts/tree/master/charts/mongodb) Helm chart, customized for local development purposes.

Detailed info: https://github.com/groundhog2k/helm-charts/tree/master/charts/mongodb

# Requirements

Before deploying this chart, please ensure:

1. Kubernetes secret exists in the target namespace with:
   - Name: `your-secret-name` (configurable via `existingSecret.name`)
   - Required keys:
     ```yaml
     mongodb-uri: "<URI-for-mongodb-access>"
     ```

2. MongoDB is installed and accessible

## Usage

1. Add the required Helm repositories:

```bash
# Add MongoDB repository
helm repo add groundhog2k https://groundhog2k.github.io/helm-charts/

# Add Prometheus Community repository for MongoDB Exporter
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
```

2. Install the MongoDB chart and MongoDB Exporter using the custom values:
```bash

# Install MongoDB
helm upgrade --install guestbook-mongodb groundhog2k/mongodb -f ./values.yaml -n mongodb --create-namespace

# Install MongoDB Exporter
helm upgrade --install mongodb-exporter prometheus-community/prometheus-mongodb-exporter -f ./mongodb-exporter.yaml -n mongodb
```

## Introduction

This chart uses the original [MongoDB image from Docker Hub](https://hub.docker.com/_/mongo/) to deploy a stateful MongoDB instance in a Kubernetes cluster.

It fully supports deployment of the multi-architecture docker image.

Additionally, this setup includes the [MongoDB Exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-mongodb-exporter) for Prometheus monitoring, which collects and exports various MongoDB metrics.

## Prerequisites

- Kubernetes 1.12+
- Helm 3.x
- PV provisioner support in the underlying infrastructure

## Configuration

Configuration adjustments applied via:
- MongoDB: [values.yaml](./values.yaml)
- MongoDB Exporter: [mongodb-exporter.yaml](./mongodb-exporter.yaml)
