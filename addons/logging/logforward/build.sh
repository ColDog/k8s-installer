#!/usr/bin/env bash

set -e

CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main github.com/coldog/kube-sys/addons/logging/logforward

docker build -t coldog/fluentd-logforward .
docker push coldog/fluentd-logforward

rm main
