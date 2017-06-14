#!/usr/bin/bash

set -e

role="$1"
cn="$2"

out=$( /usr/bin/curl --header "X-Vault-Token: $(cat /etc/vault/token)" \
    --request POST \
    -d '{"common_name": "'${cn}'","ttl": "720h","exclude_cn_from_sans":true}' \
    ${VAULT_ADDR}/v1/${K8S_CLUSTER}/pki/issue/${role} )

/usr/bin/echo "$out"

/usr/bin/echo ${out} | /usr/bin/jq -r '.data.certificate' > /etc/kubernetes/secrets/${cn}.pem
/usr/bin/echo ${out} | /usr/bin/jq -r '.data.private_key' > /etc/kubernetes/secrets/${cn}-key.pem
/usr/bin/echo ${out} | /usr/bin/jq -r '.data.issuing_ca' > /etc/kubernetes/secrets/${cn}-ca.pem

ca_b64=$( echo ${out} | /usr/bin/jq -r '.data.issuing_ca' | /usr/bin/base64 -w0)
cert_b64=$( echo ${out} | /usr/bin/jq -r '.data.certificate' | /usr/bin/base64 -w0)
key_b64=$( echo ${out} | /usr/bin/jq -r '.data.private_key' | /usr/bin/base64 -w0)

/usr/bin/cat > /etc/kubernetes/secrets/${cn}.kubeconfig <<EOF
apiVersion: v1
kind: Config
default-context: default
clusters:
- name: ${K8S_CLUSTER}
  cluster:
    server: https://${K8S_API}
    certificate-authority-data: ${ca_b64}
users:
- name: ${cn}
  user:
    client-certificate-data: ${cert_b64}
    client-key-data: ${key_b64}
contexts:
- context:
    cluster: ${K8S_CLUSTER}
    user: ${cn}
  name: default
EOF
