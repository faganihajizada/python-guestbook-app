# guestbook-service

The Guestbook sample from https://github.com/GoogleCloudPlatform/cloud-code-samples/tree/v1/python/python-guestbook

Details of the challenge: [instructions.md](instructions.md)

## Architecture Diagram

![Architecture Diagram](./docs/architecture-diagram.png)

## Helm Chart Structure

```
├── charts
│   ├── guestbook-backend
│   │   ├── Chart.yaml
│   │   ├── README.md
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
│   │   │   └── serviceaccount.yaml
│   │   └── values.yaml
│   ├── guestbook-frontend
│   │   ├── Chart.yaml
│   │   ├── README.md
│   │   ├── dashboards
│   │   │   └── guestbook-frontend.json
│   │   ├── templates
│   │   │   ├── _helpers.tpl
│   │   │   ├── deployment.yaml
│   │   │   ├── grafana-dashboard.yaml
│   │   │   ├── hpa.yaml
│   │   │   ├── ingress.yaml
│   │   │   ├── pdb.yaml
│   │   │   ├── prometheus-rules.yaml
│   │   │   ├── service.yaml
│   │   │   └── serviceaccount.yaml
│   │   └── values.yaml
│   ├── kube-prometheus-stack
│   │   ├── README.md
│   │   └── values.yaml
│   └── mongodb
│       ├── README.md
│       ├── mongodb-exporter.yaml
│       └── values.yaml
```
