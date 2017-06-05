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

data "aws_s3_bucket_object" "kubelet_binary_checksum" {
  bucket = "${var.state_bucket}"
  key    = "binaries/${var.kubernetes_version}/kubelet.checksum.txt"
}

data "ignition_file" "kubelet_binary" {
  path       = "/var/lib/kubernetes/bin/kubelet"
  mode       = 0700
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/binaries/${var.kubernetes_version}/kubelet"
    verification = "${data.aws_s3_bucket_object.kubelet_binary_checksum.body}"
  }
}

data "aws_s3_bucket_object" "kubeproxy_binary_checksum" {
  bucket = "${var.state_bucket}"
  key    = "binaries/${var.kubernetes_version}/kube-proxy.checksum.txt"
}

data "ignition_file" "kubeproxy_binary" {
  path       = "/var/lib/kubernetes/bin/kube-proxy"
  mode       = 0700
  filesystem = "root"

  source {
    source       = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/binaries/${var.kubernetes_version}/kube-proxy"
    verification = "${data.aws_s3_bucket_object.kubeproxy_binary_checksum.body}"
  }
}
