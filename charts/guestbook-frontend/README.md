# Guestbook Frontend

A Helm chart for Guestbook Frontend Service

## Introduction

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

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `true` |  |
| autoscaling.maxReplicas | int | `5` |  |
| autoscaling.minReplicas | int | `2` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| backend.port | int | `8080` |  |
| backend.service | string | `"guestbook-backend.guestbook-backend.svc.cluster.local"` |  |
| deployment.annotations | object | `{}` |  |
| deployment.containerPort | int | `8080` |  |
| deployment.labels.tier | string | `"frontend"` |  |
| deployment.name | string | `"frontend"` |  |
| deployment.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| deployment.port | int | `8080` |  |
| deployment.replicas | int | `1` |  |
| deployment.strategy.rollingUpdate.maxSurge | int | `1` |  |
| deployment.strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| deployment.strategy.type | string | `"RollingUpdate"` |  |
| deployment.terminationGracePeriodSeconds | int | `30` |  |
| fullnameOverride | string | `""` | String to fully override frontend.fullname |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"localhost:5000/python-guestbook-frontend"` |  |
| image.tag | string | `"latest"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/"` |  |
| ingress.className | string | `"nginx"` |  |
| ingress.enabled | bool | `true` |  |
| ingress.hosts[0].host | string | `"localhost"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| monitoring.grafanaDashboards.enabled | bool | `true` |  |
| monitoring.namespace | string | `"monitoring"` |  |
| monitoring.prometheusOperator.instance | string | `"kube-prometheus-stack"` |  |
| monitoring.prometheusOperator.name | string | `"kube-prometheus-stack"` |  |
| monitoring.prometheusOperator.release | string | `"kube-prometheus-stack"` |  |
| monitoring.prometheusRules.enabled | bool | `true` |  |
| nameOverride | string | `""` | String to partially override frontend.fullname |
| nodeSelector | object | `{}` |  |
| pdb.enabled | bool | `false` |  |
| pdb.minAvailable | int | `1` |  |
| podSecurityContext.fsGroup | int | `1000` |  |
| probes.liveness.failureThreshold | int | `3` |  |
| probes.liveness.initialDelaySeconds | int | `10` |  |
| probes.liveness.path | string | `"/"` |  |
| probes.liveness.periodSeconds | int | `10` |  |
| probes.liveness.successThreshold | int | `1` |  |
| probes.liveness.timeoutSeconds | int | `1` |  |
| probes.readiness.failureThreshold | int | `3` |  |
| probes.readiness.initialDelaySeconds | int | `5` |  |
| probes.readiness.path | string | `"/"` |  |
| probes.readiness.periodSeconds | int | `10` |  |
| probes.readiness.successThreshold | int | `1` |  |
| probes.readiness.timeoutSeconds | int | `1` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.annotations | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
