#!/usr/bin/env bash

cluster=$1
network=$2

/usr/bin/etcdctl set /flanneld/${cluster}/config "{\"Network\":\"$network\",\"Backend\":{\"Type\":\"vxlan\"}}"
