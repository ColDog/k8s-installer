#!/usr/bin/bash

role="$1"
cn="$2"
hosts="$3"
ips="$4"

out=$( /usr/bin/curl --header "X-Vault-Token: $(cat /etc/vault/token)" \
    --request POST \
    -d '{"common_name": "'${cn}'","ip_sans": "'${ips}'","alt_names": "'${hosts}'","ttl": "8670h","exclude_cn_from_sans":true}' \
    ${VAULT_ADDR}/v1/${K8S_CLUSTER}/pki/issue/${role} )

/usr/bin/echo ${out} | /usr/bin/jq '.data.certificate' > /etc/kubernetes/secrets/${cn}.pem
/usr/bin/echo ${out} | /usr/bin/jq '.data.private_key' > /etc/kubernetes/secrets/${cn}-key.pem
/usr/bin/echo ${out} | /usr/bin/jq '.data.issuing_ca' > /etc/kubernetes/secrets/${cn}-ca.pem
