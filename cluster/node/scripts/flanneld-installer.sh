#!/usr/bin/bash

/usr/bin/mkdir -p /opt/downloads/
/usr/bin/curl -L -o /opt/downloads/flanneld.tgz "https://s3-us-west-2.amazonaws.com/k8s.dist.coldog.xyz/flanneld-amd64-${FLANNELD_VERSION}.tgz"
/usr/bin/tar -xvf /opt/downloads/flanneld.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/flanneld-amd64-${FLANNELD_VERSION} /opt/bin/flanneld
