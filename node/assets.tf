data "aws_region" "current" {
  current = true
}

// CA
// ====

data "aws_s3_bucket_object" "ca_pem_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/ca/ca.pem.checksum.txt"
}

data "ignition_file" "ca_pem" {
  path       = "/etc/kubernetes/secrets/ca.pem"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/ca/ca.pem"
    verification = "${data.aws_s3_bucket_object.ca_pem_checksum.body}"
  }
}

// Kubelet
// ====

data "aws_s3_bucket_object" "kubelet_kubeconfig_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/kubelet/kubelet.kubeconfig.checksum.txt"
}

data "ignition_file" "kubelet_kubeconfig" {
  path       = "/etc/kubernetes/secrets/kubelet.kubeconfig"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/kubelet/kubelet.kubeconfig"
    verification = "${data.aws_s3_bucket_object.kubelet_kubeconfig_checksum.body}"
  }
}

data "aws_s3_bucket_object" "kubelet_pem_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/kubelet/kubelet.pem.checksum.txt"
}

data "ignition_file" "kubelet_pem" {
  path       = "/etc/kubernetes/secrets/kubelet.pem"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/kubelet/kubelet.pem"
    verification = "${data.aws_s3_bucket_object.kubelet_pem_checksum.body}"
  }
}

data "aws_s3_bucket_object" "kubelet_key_pem_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/kubelet/kubelet-key.pem.checksum.txt"
}

data "ignition_file" "kubelet_key_pem" {
  path       = "/etc/kubernetes/secrets/kubelet-key.pem"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/kubelet/kubelet-key.pem"
    verification = "${data.aws_s3_bucket_object.kubelet_key_pem_checksum.body}"
  }
}

// ApiServer
// ====

data "aws_s3_bucket_object" "apiserver_pem_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/apiserver/apiserver.pem.checksum.txt"
}

data "ignition_file" "apiserver_pem" {
  path       = "/etc/kubernetes/secrets/apiserver.pem"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/apiserver/apiserver.pem"
    verification = "${data.aws_s3_bucket_object.apiserver_pem_checksum.body}"
  }
}

data "aws_s3_bucket_object" "apiserver_key_pem_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/apiserver/apiserver-key.pem.checksum.txt"
}

data "ignition_file" "apiserver_key_pem" {
  path       = "/etc/kubernetes/secrets/apiserver-key.pem"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/apiserver/apiserver-key.pem"
    verification = "${data.aws_s3_bucket_object.apiserver_key_pem_checksum.body}"
  }
}

// SvcAccount
// ====

data "aws_s3_bucket_object" "svcaccount_pem_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/svcaccount/svcaccount.pem.checksum.txt"
}

data "ignition_file" "svcaccount_pem" {
  path       = "/etc/kubernetes/secrets/svcaccount.pem"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/svcaccount/svcaccount.pem"
    verification = "${data.aws_s3_bucket_object.svcaccount_pem_checksum.body}"
  }
}

data "aws_s3_bucket_object" "svcaccount_key_pem_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/svcaccount/svcaccount-key.pem.checksum.txt"
}

data "ignition_file" "svcaccount_key_pem" {
  path       = "/etc/kubernetes/secrets/svcaccount-key.pem"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/svcaccount/svcaccount-key.pem"
    verification = "${data.aws_s3_bucket_object.svcaccount_key_pem_checksum.body}"
  }
}

// Controller
// ====

data "aws_s3_bucket_object" "controller_kubeconfig_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/controller/controller.kubeconfig.checksum.txt"
}

data "ignition_file" "controller_kubeconfig" {
  path       = "/etc/kubernetes/secrets/controller.kubeconfig"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/controller/controller.kubeconfig"
    verification = "${data.aws_s3_bucket_object.controller_kubeconfig_checksum.body}"
  }
}

data "aws_s3_bucket_object" "controller_pem_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/controller/controller.pem.checksum.txt"
}

data "ignition_file" "controller_pem" {
  path       = "/etc/kubernetes/secrets/controller.pem"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/controller/controller.pem"
    verification = "${data.aws_s3_bucket_object.controller_pem_checksum.body}"
  }
}

data "aws_s3_bucket_object" "controller_key_pem_checksum" {
  bucket = "${var.state_bucket}"
  key    = "secrets/controller/controller-key.pem.checksum.txt"
}

data "ignition_file" "controller_key_pem" {
  path       = "/etc/kubernetes/secrets/controller-key.pem"
  mode       = 0600
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/secrets/controller/controller-key.pem"
    verification = "${data.aws_s3_bucket_object.controller_key_pem_checksum.body}"
  }
}

// Binaries
// ====

variable "bin_host" {
  default = "https://s3-us-west-2.amazonaws.com/k8s.dist.coldog.xyz"
}

data "ignition_file" "kubeproxy_installer" {
  path       = "/opt/bin/kubeproxy-installer"
  mode       = 0700
  filesystem = "root"
  content    = <<EOF
#!/usr/bin/bash
/usr/bin/mkdir -p /opt/downloads/
/usr/bin/curl -L -o /opt/downloads/kube-proxy.tgz '${var.bin_host}/kube-proxy-amd64-${var.kubernetes_version}.tgz'
/usr/bin/tar -xvf /opt/downloads/kube-proxy.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/kube-proxy-amd64-${var.kubernetes_version} /opt/bin/kube-proxy
EOF
}

data "ignition_file" "kubelet_installer" {
  path       = "/opt/bin/kubelet-installer"
  mode       = 0700
  filesystem = "root"
  content    = <<EOF
#!/usr/bin/bash
/usr/bin/mkdir -p /opt/downloads/
/usr/bin/curl -L -o /opt/downloads/kubelet.tgz '${var.bin_host}/kubelet-amd64-${var.kubernetes_version}.tgz'
/usr/bin/tar -xvf /opt/downloads/kubelet.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/kubelet-amd64-${var.kubernetes_version} /opt/bin/kubelet
EOF
}

data "ignition_file" "flanneld_installer" {
  path       = "/opt/bin/flanneld-installer"
  mode       = 0700
  filesystem = "root"
  content    = <<EOF
#!/usr/bin/bash
/usr/bin/mkdir -p /opt/downloads/
/usr/bin/curl -L -o /opt/downloads/flanneld.tgz '${var.bin_host}/flanneld-amd64-${var.flanneld_version}.tgz'
/usr/bin/tar -xvf /opt/downloads/flanneld.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/flanneld-amd64-${var.flanneld_version} /opt/bin/flanneld
EOF
}

data "ignition_file" "cni_installer" {
  path       = "/opt/bin/cni-installer"
  mode       = 0700
  filesystem = "root"
  content    = <<EOF
#!/usr/bin/bash
/usr/bin/mkdir -p /opt/downloads/ /opt/cni/bin/
/usr/bin/curl -L -o /opt/downloads/cni.tgz '${var.bin_host}/cni-amd64-${var.cni_version}.tgz'
/usr/bin/tar -xvf /opt/downloads/cni.tgz -C /opt/cni/bin/
EOF
}
