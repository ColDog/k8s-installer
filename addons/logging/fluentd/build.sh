#!/usr/bin/env bash

docker build -t coldog/fluentd-collector .
docker push coldog/fluentd-collector
