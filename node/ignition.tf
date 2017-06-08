data "ignition_config" "master" {
  systemd = [
    // System
    "${data.ignition_systemd_unit.metadata.id}",
    "${data.ignition_systemd_unit.docker.id}",
    "${data.ignition_systemd_unit.logger.id}",

    // Kubernetes
    "${data.ignition_systemd_unit.controllermanager.id}",
    "${data.ignition_systemd_unit.scheduler.id}",
    "${data.ignition_systemd_unit.apiserver.id}",
  ]

  files = [
    // Installers
    "${data.ignition_file.cni_installer.id}",
    "${data.ignition_file.flanneld_installer.id}",
    "${data.ignition_file.kubeproxy_installer.id}",
    "${data.ignition_file.kubelet_installer.id}",

    // Secrets / SSL
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
    // System
    "${data.ignition_systemd_unit.metadata.id}",
    "${data.ignition_systemd_unit.docker.id}",
    "${data.ignition_systemd_unit.logger.id}",

    // Kubernetes
    "${data.ignition_systemd_unit.kubelet.id}",
    "${data.ignition_systemd_unit.flanneld.id}",
    "${data.ignition_systemd_unit.kubeproxy.id}",
  ]

  files = [
    // Option files
    "${data.ignition_file.cni_opts.id}",

    // Installers
    "${data.ignition_file.cni_installer.id}",
    "${data.ignition_file.flanneld_installer.id}",
    "${data.ignition_file.kubeproxy_installer.id}",
    "${data.ignition_file.kubelet_installer.id}",

    // Secrets / SSL
    "${data.ignition_file.kubelet_kubeconfig.id}",
    "${data.ignition_file.kubelet_pem.id}",
    "${data.ignition_file.kubelet_key_pem.id}",
    "${data.ignition_file.svcaccount_pem.id}",
    "${data.ignition_file.svcaccount_key_pem.id}",
  ]
}

data "ignition_file" "cni_opts" {
  filesystem = "root"
  path = "/etc/cni/net.d/10-flannel.conf"

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

data "ignition_systemd_unit" "metadata" {
  name   = "coreos-metadata.service"
  enable = true
}

data "ignition_systemd_unit" "docker" {
  name   = "docker.service"
  enable = true
}

data "ignition_systemd_unit" "kubelet" {
  name   = "kubelet.service"
  enable = true

  content = <<EOF
[Unit]
Description=KubernetesKubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStartPre=/opt/bin/kubelet-installer
ExecStartPre=/opt/bin/cni-installer
ExecStart=/opt/bin/kubelet \
  --api-servers=https://${var.api_server} \
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

data "ignition_systemd_unit" "kubeproxy" {
  name   = "kubeproxy.service"
  enable = true

  content = <<EOF
[Unit]
Description=KubernetesKubeProxy
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStartPre=/opt/bin/kubeproxy-installer
ExecStart=/opt/bin/kube-proxy \
  --cluster-cidr=${var.pod_network} \
  --masquerade-all=true \
  --kubeconfig=/etc/kubernetes/secrets/kubelet.kubeconfig \
  --proxy-mode=iptables \
  --v=2
Restart=on-failure
RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "flanneld" {
  name = "flannel.service"
  enable = true

  content = <<EOF
[Unit]
Description=FlannelDaemon
Documentation=https://github.com/coreos/flannel
Requires=coreos-metadata.service
After=coreos-metadata.service

[Service]
EnvironmentFile=/run/metadata/coreos
ExecStartPre=/opt/bin/flanneld-installer
ExecStart=/opt/bin/flanneld \
  --iface=$${COREOS_EC2_IPV4_LOCAL} \
  --etcd-endpoints=${join(",", var.etcd_nodes)}
Restart=on-failure
RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "logger" {
  name   = "logger.service"
  enable = true

  content = <<EOF
[Unit]
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/docker stop logger.service
ExecStartPre=-/usr/bin/docker rm logger.service
ExecStart=/usr/bin/bash \
  -c '/usr/bin/journalctl -o short-iso -f | /usr/bin/docker run -i --name=logger.service coldog/awslogger -stream=$(hostname) -group=${var.cluster_name} -region=us-west-2'
ExecStop=/usr/bin/docker stop logger.service
Restart=on-failure
RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "apiserver" {
  name   = "apiserver.service"
  enable = true

  content = <<EOF
[Unit]
Description=KubernetesApiServer
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStartPre=-/usr/bin/docker stop apiserver.service
ExecStartPre=-/usr/bin/docker rm apiserver.service
ExecStart=/usr/bin/docker run --name=apiserver.service \
  -p 443:443 \
  -p 127.0.0.1:80:80 \
  -v /etc/kubernetes/secrets:/etc/kubernetes/secrets \
  quay.io/coreos/hyperkube:${var.kubernetes_version}_coreos.0 \
  /hyperkube \
  apiserver \
  --v=1 \
  --advertise-address=0.0.0.0 \
  --bind-address=0.0.0.0 \
  --secure-port=443 \
  --insecure-port=80 \
  --insecure-bind-address=0.0.0.0 \
  --service-cluster-ip-range=${var.service_ip_range} \
  --etcd-servers=${join(",", var.etcd_nodes)} \
  --client-ca-file=/etc/kubernetes/secrets/ca.pem \
  --service-account-key-file=/etc/kubernetes/secrets/svcaccount-key.pem \
  --kubelet-certificate-authority=/etc/kubernetes/secrets/ca.pem \
  --kubelet-client-certificate=/etc/kubernetes/secrets/kubelet.pem \
  --kubelet-client-key=/etc/kubernetes/secrets/kubelet-key.pem \
  --tls-ca-file=/etc/kubernetes/secrets/ca.pem \
  --tls-cert-file=/etc/kubernetes/secrets/apiserver.pem \
  --tls-private-key-file=/etc/kubernetes/secrets/apiserver-key.pem \
  --v=2
ExecStop=/usr/bin/docker stop apiserver.service

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "controllermanager" {
  name   = "controllermanager.service"
  enable = true

  content = <<EOF
[Unit]
Description=KubernetesControllerManager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStartPre=-/usr/bin/docker stop controllermanager.service
ExecStartPre=-/usr/bin/docker rm controllermanager.service
ExecStart=/usr/bin/docker run --name=controllermanager.service \
  -v /etc/kubernetes/secrets:/etc/kubernetes/secrets \
  quay.io/coreos/hyperkube:${var.kubernetes_version}_coreos.0 \
  /hyperkube \
  controller-manager \
  --address=0.0.0.0 \
  --allocate-node-cidrs=true \
  --cluster-cidr=${var.pod_network} \
  --service-cluster-ip-range=${var.service_ip_range} \
  --kubeconfig=/etc/kubernetes/secrets/controller.kubeconfig \
  --cluster-name=${var.cluster_name} \
  --leader-elect=true \
  --root-ca-file=/etc/kubernetes/secrets/ca.pem \
  --service-account-private-key-file=/etc/kubernetes/secrets/svcaccount-key.pem \
  --v=2
ExecStop=/usr/bin/docker stop controllermanager.service

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "scheduler" {
  name   = "scheduler.service"
  enable = true

  content = <<EOF
[Unit]
Description=KubernetesScheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStartPre=-/usr/bin/docker stop scheduler.service
ExecStartPre=-/usr/bin/docker rm scheduler.service
ExecStart=/usr/bin/docker run --name=scheduler.service \
  -v /etc/kubernetes/secrets:/etc/kubernetes/secrets \
  quay.io/coreos/hyperkube:${var.kubernetes_version}_coreos.0 \
  /hyperkube \
  scheduler \
  --leader-elect=true \
  --kubeconfig=/etc/kubernetes/secrets/controller.kubeconfig \
  --v=2
ExecStop=/usr/bin/docker stop scheduler.service

[Install]
WantedBy=multi-user.target
EOF
}
