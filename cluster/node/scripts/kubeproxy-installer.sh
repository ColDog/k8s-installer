#!/usr/bin/bash

if [ -z ${K8S_VERSION} ]; then
    exit 1
fi

if [ -f /opt/installed/kube-proxy-${K8S_VERSION} ]; then
    exit 0
fi

/usr/bin/curl -L -o /opt/downloads/kube-proxy.tgz "${ASSET_URL}/kube-proxy-amd64-${K8S_VERSION}.tgz"
/usr/bin/tar -xvf /opt/downloads/kube-proxy.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/kube-proxy-amd64-${K8S_VERSION} /opt/bin/kube-proxy

/usr/bin/touch /opt/installed/kube-proxy-${K8S_VERSION}
