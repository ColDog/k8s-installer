#!/usr/bin/bash

/usr/bin/curl -L -o /opt/downloads/cni.tgz "https://s3-us-west-2.amazonaws.com/k8s.dist.coldog.xyz/cni-amd64-${CNI_VERSION}.tgz"
/usr/bin/tar -xvf /opt/downloads/cni.tgz -C /opt/cni/bin/
