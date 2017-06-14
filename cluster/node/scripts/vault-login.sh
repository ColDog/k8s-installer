#!/usr/bin/env bash

set -e

if [ -f /etc/vault/token ]; then
    exit 0
fi

role="$1"

data=$( curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n' )
auth=$( curl -X POST "$VAULT_ADDR/v1/auth/aws-ec2/login" -d '{"role":"'${role}'", "pkcs7":"'${data}'"}' )
token=$( echo ${auth} | jq -r '.auth.client_token' )

echo "$auth"
mkdir -p /etc/vault
echo -n "$token" > /etc/vault/token
