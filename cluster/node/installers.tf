variable "bin_host" {
  default = "https://s3-us-west-2.amazonaws.com/k8s.dist.coldog.xyz"
}

data "ignition_file" "kubeproxy_installer" {
  path       = "/opt/bin/kubeproxy-installer"
  mode       = 0700
  filesystem = "root"

  content {
    content = <<EOF
#!/usr/bin/bash
/usr/bin/mkdir -p /opt/downloads/
/usr/bin/curl -L -o /opt/downloads/kube-proxy.tgz '${var.bin_host}/kube-proxy-amd64-${var.kubernetes_version}.tgz'
/usr/bin/tar -xvf /opt/downloads/kube-proxy.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/kube-proxy-amd64-${var.kubernetes_version} /opt/bin/kube-proxy
EOF
  }
}

data "ignition_file" "kubelet_installer" {
  path       = "/opt/bin/kubelet-installer"
  mode       = 0700
  filesystem = "root"

  content {
    content = <<EOF
#!/usr/bin/bash
/usr/bin/mkdir -p /opt/downloads/
/usr/bin/curl -L -o /opt/downloads/kubelet.tgz '${var.bin_host}/kubelet-amd64-${var.kubernetes_version}.tgz'
/usr/bin/tar -xvf /opt/downloads/kubelet.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/kubelet-amd64-${var.kubernetes_version} /opt/bin/kubelet
EOF
  }
}

data "ignition_file" "flanneld_installer" {
  path       = "/opt/bin/flanneld-installer"
  mode       = 0700
  filesystem = "root"

  content {
    content = <<EOF
#!/usr/bin/bash
/usr/bin/mkdir -p /opt/downloads/
/usr/bin/curl -L -o /opt/downloads/flanneld.tgz '${var.bin_host}/flanneld-amd64-${var.flanneld_version}.tgz'
/usr/bin/tar -xvf /opt/downloads/flanneld.tgz -C /opt/bin/
/usr/bin/mv /opt/bin/flanneld-amd64-${var.flanneld_version} /opt/bin/flanneld
EOF
  }
}

data "ignition_file" "cni_installer" {
  path       = "/opt/bin/cni-installer"
  mode       = 0700
  filesystem = "root"

  content {
    content = <<EOF
#!/usr/bin/bash
/usr/bin/mkdir -p /opt/downloads/ /opt/cni/bin/
/usr/bin/curl -L -o /opt/downloads/cni.tgz '${var.bin_host}/cni-amd64-${var.cni_version}.tgz'
/usr/bin/tar -xvf /opt/downloads/cni.tgz -C /opt/cni/bin/
EOF
  }
}
