#!/usr/bin/bash

if [ -z ${CNI_VERSION} ]; then
    exit 1
fi

if [ -f /opt/installed/cni-${CNI_VERSION} ]; then
    exit 0
fi

/usr/bin/curl -L -o /opt/downloads/cni.tgz "${ASSET_URL}/cni-amd64-${CNI_VERSION}.tgz"
/usr/bin/tar -xvf /opt/downloads/cni.tgz -C /opt/cni/bin/

/usr/bin/touch /opt/installed/cni-${CNI_VERSION}
