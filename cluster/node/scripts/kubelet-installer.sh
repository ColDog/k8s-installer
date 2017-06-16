#!/usr/bin/bash

if [ -z ${K8S_VERSION} ]; then
    exit 1
fi

if [ -f /opt/installed/kubelet-${K8S_VERSION} ]; then
    exit 0
fi

/usr/bin/curl -L -o /opt/downloads/kubelet.tgz "${ASSET_URL}/kubelet-amd64-${K8S_VERSION}.tgz"
/usr/bin/tar -xvf /opt/downloads/kubelet.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/kubelet-amd64-${K8S_VERSION} /opt/bin/kubelet

/usr/bin/touch /opt/installed/kubelet-${K8S_VERSION}
