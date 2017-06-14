#!/usr/bin/bash

set -e

/usr/bin/mkdir -p /etc/kubernetes/secrets
/usr/bin/mkdir -p /opt/downloads/ /opt/cni/bin/ /opt/bin

/opt/bin/vault-login worker

/opt/bin/cni-installer
/opt/bin/flanneld-installer
/opt/bin/kubelet-installer
/opt/bin/kubeproxy-installer

/opt/bin/get-ca
/opt/bin/get-kubeconfig worker kubelet 127.0.0.1,${COREOS_EC2_IPV4_LOCAL}
/opt/bin/get-kubeconfig worker kube-proxy
