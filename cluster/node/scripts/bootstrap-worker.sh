#!/usr/bin/bash

/opt/bin/vault-login

echo "$( curl --header "X-Vault-Token: $( cat /etc/vault/token )" ${VAULT_ADDR}/v1/${K8S_CLUSTER}/pki/ca/pem )" > /etc/kubernetes/secrets/ca.pem

/opt/bin/cni-installer
/opt/bin/flanneld-installer
/opt/bin/kubelet-installer
/opt/bin/kubeproxy-installer

/opt/bin/get-kubeconfig worker kubelet
/opt/bin/get-kubeconfig worker kube-proxy
