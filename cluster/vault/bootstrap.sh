#!/usr/bin/env bash

cluster="$1"
account="$2"

set -e

cat > ${cluster}-worker.policy.hcl <<EOF
path "${cluster}/pki/issue/worker" {
    policy = "write"
}
path "${cluster}/pki/ca/pem" {
    policy = "read"
}
EOF

cat > ${cluster}-master.policy.hcl <<EOF
path "${cluster}/pki/issue/worker" {
    policy = "write"
}
path "${cluster}/pki/issue/master" {
    policy = "write"
}
path "${cluster}/pki/ca/pem" {
    policy = "read"
}
path "secret/${cluster}/token" {
    policy = "read"
}
EOF

cat "${cluster}-master.policy.hcl" | vault policy-write ${cluster}/master -
cat "${cluster}-worker.policy.hcl" | vault policy-write ${cluster}/worker -

rm "${cluster}-master.policy.hcl"
rm "${cluster}-worker.policy.hcl"

vault write auth/aws-ec2/role/worker \
    bound_iam_instance_profile_arn=arn:aws:iam::${account}:instance-profile/${cluster}_worker_profile \
    policies=${cluster}/worker

vault write auth/aws-ec2/role/master \
    bound_iam_instance_profile_arn=arn:aws:iam::${account}:instance-profile/${cluster}_master_profile \
    policies=${cluster}/master

# Setup vault PKI backend
if [ -z "$( vault mounts | grep "${cluster}/pki/" )" ]; then
    vault mount -path ${cluster}/pki pki
fi

vault mount-tune -max-lease-ttl=87600h ${cluster}/pki

ca=$( vault write ${cluster}/pki/root/generate/internal common_name=${cluster} ttl=87600h )

# Allowed to create any certificate
vault write ${cluster}/pki/roles/master \
    allow_any_name=true \
    max_ttl="720h"

# Allowed to create kubelet certificates
vault write ${cluster}/pki/roles/worker \
    allowed_domains="kubelet,kubeproxy" \
    allow_bare_domains=true \
    allow_ip_sans=true \
    allow_subdomains=false \
    max_ttl="720h"

openssl genrsa 4096 > token.key
vault write secret/${cluster}/token key=@token.key
rm token.key
