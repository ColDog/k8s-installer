#!/usr/bin/env bash

kubernetes_api="$1"
cluster_name="$2"
bucket_path="$3"

root="$PWD"

cat > ${root}/certs/resources/apiserver_csr.json <<EOF
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "${kubernetes_api}"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Cluster",
      "ST": "Oregon"
    }
  ]
}
EOF

mkdir -p ${root}/certs/secrets/ca
cd ${root}/certs/secrets/ca
cfssl gencert -initca ${root}/certs/resources/ca_csr.json | cfssljson -bare ca

function gencert() {
    mkdir -p ${root}/certs/secrets/${2}
    cd ${root}/certs/secrets/${2}
    cfssl gencert \
        -ca=${root}/certs/secrets/ca/ca.pem \
        -ca-key=${root}/certs/secrets/ca/ca-key.pem \
        -config=${root}/certs/resources/ca_config.json \
        -profile=kubernetes \
        ${root}/certs/resources/${1} | cfssljson -bare ${2}
}

gencert apiserver_csr.json apiserver
gencert svcaccount_csr.json svcaccount
gencert kubelet_csr.json kubelet
gencert controller_csr.json controller
gencert admin_csr.json admin

function gen_kubeconfig() {
    cat > ${root}/certs/secrets/${1}/${1}.kubeconfig <<EOF
apiVersion: v1
kind: Config
clusters:
- name: ${cluster_name}
  cluster:
    server: https://${kubernetes_api}:443
    certificate-authority-data: $(cat ${root}/certs/secrets/ca/ca.pem | base64)
users:
- name: ${1}
  user:
    client-certificate-data: $(cat ${root}/certs/secrets/${1}/${1}.pem | base64)
    client-key-data: $(cat ${root}/certs/secrets/${1}/${1}-key.pem | base64)
contexts:
- context:
    cluster: ${cluster_name}
    user: ${1}
EOF
}

gen_kubeconfig controller
gen_kubeconfig admin
gen_kubeconfig kubelet

aws s3 cp --content-type=text/plain --recursive ${root}/certs/secrets/ s3://${bucket_path}/secrets/
aws s3 cp --content-type=application/json --recursive ${root}/certs/resources/ s3://${bucket_path}/tlsconfig/
rm -rf ${root}/certs/secrets/
