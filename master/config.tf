resource "random_id" "master_ignition" {
  byte_length = 64

  keepers = {
    ignition_id = "${sha512(data.ignition_config.master.rendered)}"
  }
}

resource "aws_s3_bucket_object" "master_ignition" {
  acl                    = "public-read"
  bucket                 = "${var.state_bucket}"
  key                    = "ignition/master/${random_id.master_ignition.hex}.json"
  content                = "${data.ignition_config.master.rendered}"
  server_side_encryption = "AES256"
  content_type           = "application/json"
}

data "aws_region" "current" {
  current = true
}

data "ignition_config" "master_remote" {
  replace {
    source = "https://s3-${data.aws_region.current.name}.amazonaws.com/${aws_s3_bucket_object.master_ignition.bucket}/${aws_s3_bucket_object.master_ignition.key}"
    verification = "sha512-${sha512(data.ignition_config.master.rendered)}"
  }
}

data "ignition_config" "master" {
  systemd = [
    "${data.ignition_systemd_unit.apiserver.id}",
  ]

  files = [
    "${data.ignition_file.ca_pem.id}",
    "${data.ignition_file.svcaccount_pem.id}",
    "${data.ignition_file.svcaccount_key_pem.id}",
    "${data.ignition_file.apiserver_pem.id}",
    "${data.ignition_file.apiserver_key_pem.id}",
    "${data.ignition_file.kubelet_pem.id}",
    "${data.ignition_file.kubelet_key_pem.id}",
  ]
}

data "aws_s3_bucket_object" "ca_pem" {
  bucket = "${var.state_bucket}"
  key    = "secrets/ca/ca.pem"
}

data "ignition_file" "ca_pem" {
  path       = "/etc/kubernetes/secrets/ca.pem"
  mode       = 0600
  filesystem = "root"

  content {
    content = "${data.aws_s3_bucket_object.ca_pem.body}"
  }
}

data "aws_s3_bucket_object" "svcaccount_pem" {
  bucket = "${var.state_bucket}"
  key    = "secrets/svcaccount/svcaccount.pem"
}

data "ignition_file" "svcaccount_pem" {
  path       = "/etc/kubernetes/secrets/svcaccount.pem"
  mode       = 0600
  filesystem = "root"

  content {
    content = "${data.aws_s3_bucket_object.svcaccount_pem.body}"
  }
}

data "aws_s3_bucket_object" "svcaccount_key_pem" {
  bucket = "${var.state_bucket}"
  key    = "secrets/svcaccount/svcaccount-key.pem"
}

data "ignition_file" "svcaccount_key_pem" {
  path       = "/etc/kubernetes/secrets/svcaccount-key.pem"
  mode       = 0600
  filesystem = "root"

  content {
    content = "${data.aws_s3_bucket_object.svcaccount_key_pem.body}"
  }
}

data "aws_s3_bucket_object" "apiserver_pem" {
  bucket = "${var.state_bucket}"
  key    = "secrets/apiserver/apiserver.pem"
}

data "ignition_file" "apiserver_pem" {
  path       = "/etc/kubernetes/secrets/apiserver.pem"
  mode       = 0600
  filesystem = "root"

  content {
    content = "${data.aws_s3_bucket_object.apiserver_pem.body}"
  }
}

data "aws_s3_bucket_object" "apiserver_key_pem" {
  bucket = "${var.state_bucket}"
  key    = "/secrets/apiserver/apiserver-key.pem"
}

data "ignition_file" "apiserver_key_pem" {
  path       = "/etc/kubernetes/secrets/apiserver-key.pem"
  mode       = 0600
  filesystem = "root"

  content {
    content = "${data.aws_s3_bucket_object.apiserver_key_pem.body}"
  }
}

data "aws_s3_bucket_object" "kubelet_pem" {
  bucket = "${var.state_bucket}"
  key    = "/secrets/kubelet/kubelet.pem"
}

data "ignition_file" "kubelet_pem" {
  path       = "/etc/kubernetes/secrets/kubelet.pem"
  mode       = 0600
  filesystem = "root"

  content {
    content = "${data.aws_s3_bucket_object.kubelet_pem.body}"
  }
}

data "aws_s3_bucket_object" "kubelet_key_pem" {
  bucket = "${var.state_bucket}"
  key    = "/secrets/kubelet/kubelet-key.pem"
}

data "ignition_file" "kubelet_key_pem" {
  path       = "/etc/kubernetes/secrets/kubelet-key.pem"
  mode       = 0600
  filesystem = "root"

  content {
    content = "${data.aws_s3_bucket_object.kubelet_key_pem.body}"
  }
}

data "ignition_systemd_unit" "apiserver" {
  name   = "apiserver.service"
  enable = true

  content = <<EOF
[Unit]
Description=APIServer
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/docker kill kubernetes.apiserver || exit 0
ExecStartPre=-/usr/bin/docker rm kubernetes.apiserver || exit 0
ExecStart=
ExecStart=/usr/bin/docker run --name=kubernetes.apiserver -v /etc/kubernetes:/etc/kubernetes --net=host \
  ${var.hyperkube_image} \
  /hyperkube \
  apiserver \
  --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --bind-address=0.0.0.0 \
  --secure-port=443 \
  --insecure-port=80 \
  --insecure-bind-address=127.0.0.1 \
  --service-cluster-ip-range=${var.cluster_ip_range} \
  --etcd-servers=${join(",", var.etcd_nodes)} \
  --client-ca-file=/etc/kubernetes/secrets/ca.pem \
  --service-account-key-file=/etc/kubernetes/secrets/svcaccount-key.pem \
  --kubelet-certificate-authority=/etc/kubernetes/secrets/ca.pem \
  --kubelet-client-certificate=/etc/kubernetes/secrets/kubelet.pem \
  --kubelet-client-key=/etc/kubernetes/secrets/kubelet-key.pem \
  --tls-ca-file=/etc/kubernetes/secrets/ca.pem \
  --tls-cert-file=/etc/kubernetes/secrets/apiserver.pem \
  --tls-private-key-file=/etc/kubernetes/secrets/apiserver-key.pem

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "controllermanager" {
  name   = "controllermanager.service"
  enable = true

  content = <<EOF
[Unit]
Description=ControllerManager
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/docker kill kubernetes.controllermanager || exit 0
ExecStartPre=-/usr/bin/docker rm kubernetes.controllermanager || exit 0
ExecStart=
ExecStart=/usr/bin/docker run --name=kubernetes.controllermanager -v /etc/kubernetes:/etc/kubernetes --net=host \
  ${var.hyperkube_image} \
  /hyperkube \
  controller-manager \
  --address=0.0.0.0 \
  --cluster-name=kubernetes \
  --leader-elect=true \
  --master=http://127.0.0.0:80 \
  --root-ca-file=/etc/kubernetes/secrets/ca.pem \
  --service-account-private-key-file=/etc/kubernetes/secrets/svcaccount-key.pem

[Install]
WantedBy=multi-user.target
EOF
}
