#!/usr/bin/bash

set -e

/usr/bin/mkdir -p /etc/kubernetes/secrets
/usr/bin/mkdir -p /opt/downloads/ /opt/cni/bin/ /opt/bin

/opt/bin/vault-login master

/opt/bin/get-ca
/opt/bin/get-certs master apiserver ${K8S_API} 127.0.0.1
/opt/bin/get-kubeconfig master controllermanager
/opt/bin/get-kubeconfig master scheduler
