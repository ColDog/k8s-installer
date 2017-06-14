#!/usr/bin/bash

/usr/bin/echo \
    "$( curl --header "X-Vault-Token: $( cat /etc/vault/token )" ${VAULT_ADDR}/v1/${K8S_CLUSTER}/pki/ca/pem )" \
    > /etc/kubernetes/secrets/ca.pem
