#!/usr/bin/env bash

/usr/bin/curl --header "X-Vault-Token: $(cat /etc/vault/token)" ${VAULT_ADDR}/v1/secret/${K8S_CLUSTER}/token | /usr/bin/jq -r '.data.key' > /etc/kubernetes/secrets/serviceaccount-key.pem
