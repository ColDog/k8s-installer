#!/usr/bin/env bash

go install github.com/coldog/kube-sys/addons/logging/logforward
bin/test-logging | logforward -spec=NoFilterSpec -log-errors -log-messages
