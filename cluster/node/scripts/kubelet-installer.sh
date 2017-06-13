#!/usr/bin/bash

/usr/bin/mkdir -p /opt/downloads/
/usr/bin/curl -L -o /opt/downloads/kubelet.tgz "https://s3-us-west-2.amazonaws.com/k8s.dist.coldog.xyz/kubelet-amd64-${K8S_VERSION}.tgz"
/usr/bin/tar -xvf /opt/downloads/kubelet.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/kubelet-amd64-${K8S_VERSION} /opt/bin/kubelet
