{{- define "nginx.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "nginx.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}
