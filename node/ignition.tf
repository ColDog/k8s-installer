data "ignition_config" "master" {
  systemd = [
    "${data.ignition_systemd_unit.metadata.id}",
    "${data.ignition_systemd_unit.kubelet.id}",
    "${data.ignition_systemd_unit.logger.id}",
    "${data.ignition_systemd_unit.docker_opts.id}",
    "${data.ignition_systemd_unit.flannel_enable.id}",
  ]

  files = [
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

data "ignition_config" "worker" {
  systemd = [
    "${data.ignition_systemd_unit.metadata.id}",
    "${data.ignition_systemd_unit.kubelet.id}",
    "${data.ignition_systemd_unit.logger.id}",
    "${data.ignition_systemd_unit.docker_opts.id}",
    "${data.ignition_systemd_unit.flannel_enable.id}",
  ]

  files = [
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

data "ignition_file" "flannel_configure" {
  filesystem = "root"
  mode       = 0700
  path       = "/opt/bin/flannel-configure"

  content {
    content = <<EOF
#!/bin/bash
/usr/bin/mkdir -p /run/flannel/ etc/flannel

export $(cat /run/metadata/coreos)

cat > /etc/flannel/options.env <<BASH
FLANNELD_ETCD_ENDPOINTS=${join(",", var.etcd_nodes)}
FLANNELD_IFACE=$${COREOS_EC2_IPV4_LOCAL}
BASH

/usr/bin/ln -sf /etc/flannel/options.env /run/flannel/options.env
EOF
  }
}

data "ignition_systemd_unit" "metadata" {
  name = "coreos-metadata.service"
  enable = true
}

data "ignition_systemd_unit" "flannel_enable" {
  name = "flanneld.service"
  enable = true

  dropin {
    name = "40-ExecStartPre-symlink.conf"

    content = <<EOF
[Unit]
Requires=coreos-metadata.service
After=coreos-metadata.service

[Service]
EnvironmentFile=/run/metadata/coreos
ExecStartPre=/opt/bin/flannel-configure
EOF
  }
}

data "ignition_systemd_unit" "docker_opts" {
  name = "docker.service"
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

data "ignition_systemd_unit" "logger" {
  name = "logger.service"
  enable = true

  content = <<EOF
[Unit]
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/docker stop logger.service
ExecStartPre=-/usr/bin/docker rm logger.service
ExecStart=/usr/bin/bash \
  -c '/usr/bin/journalctl -o short-iso -f | /usr/bin/docker run -i --name=logger.service coldog/awslogs -stream=$(hostname) -group=${var.cluster_name} -region=us-west-2'
ExecStop=/usr/bin/docker stop logger.service
Restart=on-failure
RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}
