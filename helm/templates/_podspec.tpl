{{- /* Shared pod spec used by both the Pod (podman play kube) and the
       Deployment (real K8s) wrappers. `.Values.deployAs` switches the
       podman-only bit: the emptyDir `path` extension. See pod.yaml /
       deployment.yaml. */ -}}
{{- define "toolkit.podspec" -}}
containers:
  - name: toolkit
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    command: {{ toJson .Values.command }}
    volumeMounts:
      - name: workspace
        mountPath: {{ .Values.workspace.mountPath }}
volumes:
  {{- if eq .Values.deployAs "Pod" }}
  # Pod mode: `emptyDir.path` is a podman extension (host-dir-backed emptyDir)
  # mounting the repo root, so the project survives `play kube --replace`.
  - name: workspace
    emptyDir:
      path: {{ .Values.workspace.hostPath }}
  {{- else }}
  # Deployment mode: plain emptyDir (ephemeral) — provide the project via a PVC,
  # ConfigMap, or COPY it into the image on a real cluster.
  - name: workspace
    emptyDir: {}
  {{- end }}
{{- end -}}