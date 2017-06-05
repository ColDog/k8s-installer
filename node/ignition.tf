data "ignition_config" "master_remote" {
  replace {
    source = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/master_remote_config.json"
    verification = "sha512-${sha512(aws_s3_bucket_object.master_remote_config.content)}"
  }
}

resource "aws_s3_bucket_object" "master_remote_config" {
  bucket       = "${var.state_bucket}"
  key          = "master_remote_config.json"
  content_type = "application/json"
  content      = "${data.ignition_config.master.rendered}"
}

data "ignition_config" "master" {
  systemd = [
    "${data.ignition_systemd_unit.kubelet.id}",
    "${data.ignition_systemd_unit.flannel_enable.id}",
    "${data.ignition_systemd_unit.docker_opts.id}",
  ]

  files = [
    "${data.ignition_file.flannel_opts.id}",
    "${data.ignition_file.docker_cni_opts.id}",
    "${data.ignition_file.flannel_cni.id}",
    "${data.ignition_file.kubelet_binary.id}",
    "${data.ignition_file.kubelet_kubeconfig.id}",
    "${data.ignition_file.kubelet_pem.id}",
    "${data.ignition_file.kubelet_key_pem.id}",
    "${data.ignition_file.svcaccount_pem.id}",
    "${data.ignition_file.svcaccount_key_pem.id}",
    "${data.ignition_file.ca_pem.id}",
    "${data.ignition_file.apiserver_pem.id}",
    "${data.ignition_file.apiserver_key_pem.id}",
    "${data.ignition_file.controller_kubeconfig.id}",
    "${data.ignition_file.controller_pem.id}",
    "${data.ignition_file.controller_key_pem.id}",
  ]
}

data "ignition_config" "worker_remote" {
  replace {
    source = "https://s3-${data.aws_region.current.name}.amazonaws.com/${var.state_bucket}/worker_remote_config.json"
    verification = "sha512-${sha512(aws_s3_bucket_object.worker_remote_config.content)}"
  }
}

resource "aws_s3_bucket_object" "worker_remote_config" {
  bucket       = "${var.state_bucket}"
  key          = "worker_remote_config.json"
  content_type = "application/json"
  content      = "${data.ignition_config.worker.rendered}"
}

data "ignition_config" "worker" {
  systemd = [
    "${data.ignition_systemd_unit.kubelet.id}",
    "${data.ignition_systemd_unit.flannel_enable.id}",
    "${data.ignition_systemd_unit.docker_opts.id}",
  ]

  files = [
    "${data.ignition_file.flannel_opts.id}",
    "${data.ignition_file.docker_cni_opts.id}",
    "${data.ignition_file.flannel_cni.id}",
    "${data.ignition_file.kubelet_binary.id}",
    "${data.ignition_file.kubelet_kubeconfig.id}",
    "${data.ignition_file.kubelet_pem.id}",
    "${data.ignition_file.kubelet_key_pem.id}",
    "${data.ignition_file.svcaccount_pem.id}",
    "${data.ignition_file.svcaccount_key_pem.id}",
  ]
}

data "ignition_file" "docker_cni_opts" {
  filesystem = "root"
  path       = "/etc/kubernetes/cni/docker_opts_cni.env"

  content {
    content = <<EOF
DOCKER_OPT_BIP=""
DOCKER_OPT_IPMASQ=""
EOF
  }
}

data "ignition_file" "flannel_cni" {
  filesystem = "root"
  path       = "/etc/kubernetes/cni/net.d/10-flannel.conf"

  content {
    content = <<EOF
{
    "name": "podnet",
    "type": "flannel",
    "delegate": {
        "isDefaultGateway": true
    }
}
EOF
  }
}

data "ignition_file" "flannel_opts" {
  filesystem = "root"
  path       = "/etc/flannel/options.env"

  content {
    content = <<EOF
FLANNELD_IFACE=$${COREOS_PRIVATE_IPV4}
FLANNELD_ETCD_ENDPOINTS=${join(",", var.etcd_nodes)}
EOF
  }
}

data "ignition_systemd_unit" "flannel_enable" {
  name = "flanneld.service.d"
  enable = true

  dropin {
    name = "40-ExecStartPre-symlink.conf"

    content = <<EOF
[Service]
ExecStartPre=/usr/bin/ln -sf /etc/flannel/options.env /run/flannel/options.env
EOF
  }
}

data "ignition_systemd_unit" "docker_opts" {
  name = "docker.service.d"
  enable = true

  dropin {
    name = "40-flannel.conf"

    content = <<EOF
[Unit]
Requires=flanneld.service
After=flanneld.service
[Service]
EnvironmentFile=/etc/kubernetes/cni/docker_opts_cni.env
EOF
  }
}

data "ignition_systemd_unit" "kubelet" {
  name   = "kubelet.service"
  enable = true

  content = <<EOF
[Unit]
Description=KubernetesKubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/opt/bin/kubelet \
  --cluster-domain=cluster.local \
  --allow-privileged=true \
  --register-schedulable=false \
  --container-runtime=docker \
  --network-plugin=cni \
  --kubeconfig=/etc/kubernetes/secrets/kubelet.kubeconfig \
  --serialize-image-pulls=false \
  --register-node=true \
  --tls-cert-file=/etc/kubernetes/secrets/kubelet.pem \
  --tls-private-key-file=/etc/kubernetes/secrets/kubelet-key.pem
Restart=on-failure
RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}
