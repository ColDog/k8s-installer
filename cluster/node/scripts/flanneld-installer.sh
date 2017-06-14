#!/usr/bin/bash

if [ -z ${FLANNELD_VERSION} ]; then
    exit 1
fi

if [ -f /opt/installed/flanneld-${FLANNELD_VERSION} ]; then
    exit 0
fi

/usr/bin/curl -L -o /opt/downloads/flanneld.tgz "https://s3-us-west-2.amazonaws.com/k8s.dist.coldog.xyz/flanneld-amd64-${FLANNELD_VERSION}.tgz"
/usr/bin/tar -xvf /opt/downloads/flanneld.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/flanneld-amd64-${FLANNELD_VERSION} /opt/bin/flanneld

/usr/bin/touch /opt/installed/flanneld-${FLANNELD_VERSION}
