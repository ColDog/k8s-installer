#!/usr/bin/bash

/opt/bin/vault-login

echo "$( curl --header "X-Vault-Token: $( cat /etc/vault/token )" ${VAULT_ADDR}/v1/${K8S_CLUSTER}/pki/ca/pem )" > /etc/kubernetes/secrets/ca.pem

/opt/bin/get-certs master apiserver ${K8S_API} 127.0.0.1
/opt/bin/get-kubeconfig master controllermanager
/opt/bin/get-kubeconfig master scheduler
