#!/usr/bin/env bash

if [ "$1" == "" ]; then
    echo "Version must be provided"
    exit 1
fi

version=$1
mkdir -p binaries/${version}

curl -o binaries/${version}/kube-proxy https://storage.googleapis.com/kubernetes-release/release/${version}/bin/linux/amd64/kube-proxy
curl -o binaries/${version}/kubelet https://storage.googleapis.com/kubernetes-release/release/${version}/bin/linux/amd64/kubelet
