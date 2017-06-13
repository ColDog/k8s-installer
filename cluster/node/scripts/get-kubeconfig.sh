#!/usr/bin/bash

role="$1"
cn="$2"

out=$( /usr/bin/curl --header "X-Vault-Token: $(cat /etc/vault/token)" \
    --request POST \
    -d '{"common_name": "'${cn}'","ttl": "8670h","exclude_cn_from_sans":true}' \
    ${VAULT_ADDR}/v1/${K8S_CLUSTER}/pki/issue/${role} )

/usr/bin/echo ${out} | /usr/bin/jq '.data.certificate' > /etc/kubernetes/secrets/${cn}.pem
/usr/bin/echo ${out} | /usr/bin/jq '.data.private_key' > /etc/kubernetes/secrets/${cn}-key.pem
/usr/bin/echo ${out} | /usr/bin/jq '.data.issuing_ca' > /etc/kubernetes/secrets/${cn}-ca.pem

ca_b64=$( echo ${out} | /usr/bin/jq '.data.issuing_ca' \ base64)
cert_b64=$( echo ${out} | /usr/bin/jq '.data.certificate' \ base64)
key_b64=$( echo ${out} | /usr/bin/jq '.data.private_key' \ base64)

/usr/bin/cat > /etc/kubernetes/secrets/${role}.kubeconfig <<EOF
apiVersion: v1
kind: Config
default-context: default
clusters:
- name: ${K8S_CLUSTER}
  cluster:
    server: https://${K8S_API}:443
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
