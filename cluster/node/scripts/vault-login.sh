#!/usr/bin/env bash


data=$( curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n' )
auth=$( curl -X POST "$VAULT_ADDR/v1/auth/aws/login" -d '{"role":"master", "pkcs7":"'${data}'"}' )
token=$( echo ${auth} | jq '.auth.client_token' )

mkdir -p /etc/vault
echo -n "$token" > /etc/vault/token
