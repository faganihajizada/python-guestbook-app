# Introduction

This chart bootstraps `guestbook-frontend` deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Requirements

Before deploying this chart, please ensure:

1. The backend service is deployed and accessible
2. You have Helm 3.x installed
3. You have access to a Kubernetes cluster

## Deploy

```console
helm install guestbook-frontend ./charts/guestbook-frontend -f values.yaml --create-namespace -n [NAMESPACE]
```