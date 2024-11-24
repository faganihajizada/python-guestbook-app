# guestbook-service

The Guestbook sample from https://github.com/GoogleCloudPlatform/cloud-code-samples/tree/v1/python/python-guestbook

Details of the challenge: [instructions.md](instructions.md)

## Architecture Diagram

![Architecture Diagram](./docs/architecture-diagram.png)

## Helm Chart Structure

```
── charts
│   ├── backend
│   │   ├── Chart.yaml
│   │   ├── README.md
│   │   ├── templates
│   │   │   ├── NOTES.txt
│   │   │   ├── _helpers.tpl
│   │   │   ├── configmap.yaml
│   │   │   ├── deployment.yaml
│   │   │   ├── hpa.yaml
│   │   │   ├── pdb.yaml
│   │   │   ├── service.yaml
│   │   │   └── serviceaccount.yaml
│   │   └── values.yaml
│   ├── frontend
│   │   ├── Chart.yaml
│   │   ├── README.md
│   │   ├── templates
│   │   │   ├── NOTES.txt
│   │   │   ├── _helpers.tpl
│   │   │   ├── deployment.yaml
│   │   │   ├── hpa.yaml
│   │   │   ├── ingress.yaml
│   │   │   ├── pdb.yaml
│   │   │   ├── service.yaml
│   │   │   └── serviceaccount.yaml
│   │   └── values.yaml
│   └── mongodb(groundhog2k/mongodb)
│       └── values.yaml
│   └── prometheus-community/kube-prometheus-stack
│       └── values.yaml
```
