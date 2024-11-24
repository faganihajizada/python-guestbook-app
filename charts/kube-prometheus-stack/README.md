# Kube Prometheus Stack Deployment

This repository contains the configuration for deploying the [Kube Prometheus Stack](prometheus-community/kube-prometheus-stack) in a Kubernetes cluster using Helm.

Detailed info: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

## Usage

1. Add the Prometheus Community Helm repository:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

2. Install the Kube Prometheus Stack using the custom values:

```bash
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack -f ./values.yaml -n monitoring --create-namespace
```

## Introduction

This chart uses the original [MongoDB image from Docker Hub](https://hub.docker.com/_/mongo/) to deploy a stateful MongoDB instance in a Kubernetes cluster.

It fully supports deployment of the multi-architecture docker image.

## Prerequisites

- Kubernetes 1.12+
- Helm 3.x
- NGINX Ingress Controller installed in the cluster

## Configuration

Configuration adjustments applied via [values.yaml](./values.yaml)
