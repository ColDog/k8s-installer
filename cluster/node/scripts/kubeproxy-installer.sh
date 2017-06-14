#!/usr/bin/bash

/usr/bin/curl -L -o /opt/downloads/kube-proxy.tgz "https://s3-us-west-2.amazonaws.com/k8s.dist.coldog.xyz/kube-proxy-amd64-${K8S_VERSION}.tgz"
/usr/bin/tar -xvf /opt/downloads/kube-proxy.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/kube-proxy-amd64-${K8S_VERSION} /opt/bin/kube-proxy
