# Introduction

This chart bootstraps `guestbook-backend` deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

# Requirements

Before deploying this chart, please ensure:

1. Kubernetes secret exists in the target namespace with:
   - Name: `your-secret-name` (configurable via `mongodb.auth.secretKeys.secretName`)
   - Required keys:
     ```yaml
     USERDB_PASSWORD: "<your-mongodb-password>"
     ```

2. MongoDB is installed and accessible at the configured host (default: `guestbook-mongodb.mongodb`)

# Deploy

```console
helm install guestbook-backend /charts/guestbook-backend -f /charts/guestbook-backend/values.yaml -n [NAMESPACE]
```
