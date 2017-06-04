resource "random_id" "worker_ignition" {
  byte_length = 64

  keepers = {
    ignition_id = "${sha512(data.ignition_config.worker.rendered)}"
  }
}

resource "aws_s3_bucket_object" "worker_ignition" {
  acl                    = "public-read"
  bucket                 = "${var.state_bucket}"
  key                    = "ignition/worker/${random_id.worker_ignition.hex}.json"
  content                = "${data.ignition_config.worker.rendered}"
  server_side_encryption = "AES256"
  content_type           = "application/json"
}

data "aws_region" "current" {
  current = true
}

data "ignition_config" "worker_remote" {
  replace {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${aws_s3_bucket_object.worker_ignition.bucket}/${aws_s3_bucket_object.worker_ignition.key}"
    verification = "sha512-${sha512(data.ignition_config.worker.rendered)}"
  }
}

data "ignition_config" "worker" {
  systemd = [
    "${data.ignition_systemd_unit.kubelet.id}",
    "${data.ignition_systemd_unit.kube_proxy.id}",
  ]

  files = [
    "${data.ignition_file.kubelet_kubeconfig.id}",
    "${data.ignition_file.kubelet_pem.id}",
    "${data.ignition_file.kubelet_key_pem.id}",
    "${data.ignition_file.kubelet.id}",
    "${data.ignition_file.kube_proxy.id}",
  ]

}

data "aws_s3_bucket_object" "kubelet_kubeconfig" {
  bucket = "${var.state_bucket}"
  key    = "secrets/kubelet/kubelet.kubeconfig"
}

data "ignition_file" "kubelet_kubeconfig" {
  path       = "/etc/kubernetes/secrets/kubelet.kubeconfig"
  mode       = 0600
  filesystem = "root"

  content {
    content = "${data.aws_s3_bucket_object.kubelet_kubeconfig.body}"
  }
}

data "aws_s3_bucket_object" "kubelet_pem" {
  bucket = "${var.state_bucket}"
  key    = "secrets/kubelet/kubelet.pem"
}

data "ignition_file" "kubelet_pem" {
  path       = "/etc/kubernetes/secrets/kubelet.pem"
  mode       = 0600
  filesystem = "root"

  content {
    content = "${data.aws_s3_bucket_object.kubelet_kubeconfig.body}"
  }
}

data "aws_s3_bucket_object" "kubelet_key_pem" {
  bucket = "${var.state_bucket}"
  key    = "secrets/kubelet/kubelet-key.pem"
}

data "ignition_file" "kubelet_key_pem" {
  path       = "/etc/kubernetes/secrets/kubelet-key.pem"
  mode       = 0600
  filesystem = "root"

  content {
    content = "${data.aws_s3_bucket_object.kubelet_kubeconfig.body}"
  }
}

data "ignition_file" "kubelet" {
  path       = "/usr/bin/kubelet"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("binaries/${var.kubernetes_version}/kubelet")}"
  }
}

data "ignition_file" "kube_proxy" {
  path       = "/usr/bin/kube-proxy"
  mode       = 0700
  filesystem = "root"

  content {
    content = "${file("binaries/${var.kubernetes_version}/kube-proxy")}"
  }
}

data "ignition_systemd_unit" "kubelet" {
  name   = "kubelet.service"
  enable = true

  content = <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \
  --api-servers=${var.api_server} \
  --cluster-domain=${var.cluster_domain} \
  --allow-privileged=true \
  --container-runtime=docker \
  --network-plugin=kubenet \
  --kubeconfig=/etc/kubernetes/secrets/kubelet.kubeconfig \
  --serialize-image-pulls=false \
  --register-node=true \
  --tls-cert-file=/etc/kubernetes/secrets/kubelet.pem \
  --tls-private-key-file=/etc/kubernetes/secrets/kubelet-key.pem
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "kube_proxy" {
  name   = "kube-proxy.service"
  enable = true

  content = <<EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-proxy \
  --cluster-cidr=${var.cluster_cidr} \
  --masquerade-all=true \
  --kubeconfig=/var/lib/kube-proxy/kubelet.kubeconfig \
  --proxy-mode=iptables \
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}
