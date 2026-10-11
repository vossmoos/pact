{{- define "pact.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pact.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pact.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pact.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "pact.labels" -}}
{{ include "pact.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "pact.secretName" -}}
{{- default (printf "%s-env" (include "pact.fullname" .)) .Values.existingSecret -}}
{{- end -}}

{{/* ConfigMap keys cannot contain "/": agents/default.yaml -> agents__default.yaml */}}
{{- define "pact.configKey" -}}
{{- . | replace "/" "__" -}}
{{- end -}}

{{- define "pact.configDir" -}}
{{- if eq .Values.config.source "gitSync" -}}
{{- printf "/git/current/%s" (.Values.gitSync.path | trimAll "/") | trimSuffix "/" -}}
{{- else -}}
/config
{{- end -}}
{{- end -}}

{{- define "pact.gitSyncEnv" -}}
- name: GITSYNC_REPO
  value: {{ required "gitSync.repo is required when config.source=gitSync" .Values.gitSync.repo | quote }}
- name: GITSYNC_REF
  value: {{ .Values.gitSync.ref | quote }}
- name: GITSYNC_ROOT
  value: /git
- name: GITSYNC_LINK
  value: current
- name: GITSYNC_PERIOD
  value: {{ .Values.gitSync.period | quote }}
- name: HOME
  value: /tmp
{{- end -}}
