#!/usr/bin/bash

set -e

cn="$1"

/usr/bin/cat > /etc/kubernetes/secrets/${cn}.kubeconfig <<EOF
apiVersion: v1
kind: Config
current-context: default
clusters:
- name: ${K8S_CLUSTER}
  cluster:
    server: https://${K8S_API}
    certificate-authority: /etc/kubernetes/secrets/${cn}-ca.pem
users:
- name: ${cn}
  user:
    client-certificate: /etc/kubernetes/secrets/${cn}.pem
    client-key: /etc/kubernetes/secrets/${cn}-key.pem
contexts:
- context:
    cluster: ${K8S_CLUSTER}
    user: ${cn}
  name: default
EOF
