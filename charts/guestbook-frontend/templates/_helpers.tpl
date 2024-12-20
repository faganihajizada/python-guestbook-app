{{/*
Expand the name of the chart.
*/}}
{{- define "guestbook-frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "guestbook-frontend.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "guestbook-frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "guestbook-frontend.labels" -}}
helm.sh/chart: {{ include "guestbook-frontend.chart" . }}
{{ include "guestbook-frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "guestbook-frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "guestbook-frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Validate values */}}
{{- define "guestbook-frontend.validateValues" -}}
{{- $errors := list -}}
{{- if not .Values.backend.service -}}
  {{- $errors = append $errors "backend.service must be provided" -}}
{{- end -}}
{{- if not .Values.backend.port -}}
  {{- $errors = append $errors "backend.port must be provided" -}}
{{- end -}}
{{- if and .Values.ingress.enabled (not .Values.ingress.hosts) -}}
  {{- $errors = append $errors "ingress.hosts must be provided when ingress is enabled" -}}
{{- end -}}
{{- if not (empty $errors) -}}
{{- fail (join "\n" $errors) -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "guestbook-frontend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "guestbook-frontend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
