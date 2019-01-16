{{- define "virtual-garden.kubeconfig-controller-manager" -}}
apiVersion: v1
kind: Config
current-context: virtual-garden
contexts:
- context:
    cluster: virtual-garden
    user: kube-controller-manager
  name: virtual-garden
clusters:
- cluster:
    certificate-authority-data: {{ .Values.tls.kubeAPIServer.ca.crt | b64enc }}
    server: https://localhost:443
  name: virtual-garden
users:
- name: kube-controller-manager
  user:
    client-certificate-data: {{ .Values.tls.kubeControllerManager.crt | b64enc }}
    client-key-data: {{ .Values.tls.kubeControllerManager.key | b64enc }}
{{- end -}}

{{- define "virtual-garden.kubeconfig-gardener" -}}
apiVersion: v1
kind: Config
current-context: virtual-garden
contexts:
- context:
    cluster: virtual-garden
    user: gardener
  name: virtual-garden
clusters:
- cluster:
    certificate-authority-data: {{ .Values.tls.kubeAPIServer.ca.crt | b64enc }}
    server: https://{{ .Values.apiServer.serviceName }}:443
  name: virtual-garden
users:
- name: gardener
  user:
    client-certificate-data: {{ .Values.tls.gardener.crt | b64enc }}
    client-key-data: {{ .Values.tls.gardener.key | b64enc }}
{{- end -}}

{{- define "virtual-garden.kubeconfig-admin" -}}
apiVersion: v1
kind: Config
current-context: virtual-garden
contexts:
- context:
    cluster: virtual-garden
    user: admin
  name: virtual-garden
clusters:
- cluster:
    certificate-authority-data: {{ .Values.tls.kubeAPIServer.ca.crt | b64enc }}
    server: https://{{ .Values.apiServer.hostname }}:443
  name: virtual-garden
users:
- name: admin
  user:
    client-certificate-data: {{ .Values.tls.admin.crt | b64enc }}
    client-key-data: {{ .Values.tls.admin.key | b64enc }}
{{- end -}}
