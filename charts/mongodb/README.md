# MongoDB Helm Chart

This is a configuration values file for the [groundhog2k/mongodb](https://github.com/groundhog2k/helm-charts/tree/master/charts/mongodb) Helm chart, customized for local development purposes.

Detailed info: https://github.com/groundhog2k/helm-charts/tree/master/charts/mongodb

## Usage

```
	helm upgrade --install guestbook-mongodb groundhog2k/mongodb \
	-f ./values.yaml -n mongodb --create-namespace
```

## Introduction

This chart uses the original [MongoDB image from Docker Hub](https://hub.docker.com/_/mongo/) to deploy a stateful MongoDB instance in a Kubernetes cluster.

It fully supports deployment of the multi-architecture docker image.

## Prerequisites

- Kubernetes 1.12+
- Helm 3.x
- PV provisioner support in the underlying infrastructure
