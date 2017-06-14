#!/usr/bin/env bash

set -e

if [ -f /etc/vault/token ]; then
    exit 0
fi

role="$1"

nonce=""
if [ -f /etc/vault/nonce ]; then
    nonce=$(cat /etc/vault/nonce)
fi


data=$( /usr/bin/curl -f -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n' )
auth=$( /usr/bin/curl -s -f -X POST "$VAULT_ADDR/v1/auth/aws-ec2/login" -d '{"role":"'${role}'", "pkcs7":"'${data}'", "nonce": "'${nonce}'"}' )

token=$( /usr/bin/echo ${auth} | /usr/bin/jq -r '.auth.client_token' )
nonce=$( /usr/bin/echo ${auth} | /usr/bin/jq -r '.auth.metadata.nonce' )

/usr/bin/echo "$auth"

/usr/bin/mkdir -p /etc/vault
/usr/bin/echo -n "$token" > /etc/vault/token
/usr/bin/echo -n "$nonce" > /etc/vault/nonce
