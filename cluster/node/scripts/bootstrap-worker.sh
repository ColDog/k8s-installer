#!/usr/bin/bash

set -e

/usr/bin/etcdctl \
  --endpoints=${K8S_ETCD_NODES} \
  set /flanneld/${K8S_CLUSTER}/config '{"Network": "'${K8S_POD_NETWORK}'"}'

/usr/bin/mkdir -p /etc/kubernetes/secrets
/usr/bin/mkdir -p /opt/downloads/ /opt/cni/bin/ /opt/bin /opt/installed

/opt/bin/vault-login worker

/opt/bin/cni-installer
/opt/bin/flanneld-installer
/opt/bin/kubelet-installer
/opt/bin/kubeproxy-installer

/opt/bin/get-certs worker kubelet "" 127.0.0.1,${COREOS_EC2_IPV4_LOCAL}
/opt/bin/get-certs worker kubeproxy

/opt/bin/get-kubeconfig kubelet
/opt/bin/get-kubeconfig kubeproxy
