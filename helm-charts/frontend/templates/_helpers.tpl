{{- define "frontend.name" -}}
{{- .Chart.Name | trim | lower -}}
{{- end }}

{{- define "frontend.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trim | trunc 63 | trimSuffix "-" | lower -}}
{{- else }}
{{- printf "%s-%s" (.Release.Name | trim | lower) (.Chart.Name | trim | lower) | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end }}
