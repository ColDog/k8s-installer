data "ignition_file" "cni_opts" {
  filesystem = "root"
  path       = "/etc/cni/net.d/10-flannel.conf"

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

data "ignition_systemd_unit" "bootstrap_master" {
  name   = "bootstrap.service"
  enable = true

  content = <<EOF
[Unit]
Description=BootstrapService
Requires=coreos-metadata.service
After=coreos-metadata.service

[Service]
Type=oneshot
EnvironmentFile=/run/metadata/coreos
EnvironmentFile=/etc/kubernetes/options.env
ExecStart=/opt/bin/bootstrap-master

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "bootstrap_worker" {
  name   = "bootstrap.service"
  enable = true

  content = <<EOF
[Unit]
Description=BootstrapService
Requires=coreos-metadata.service
After=coreos-metadata.service

[Service]
Type=oneshot
EnvironmentFile=/run/metadata/coreos
EnvironmentFile=/etc/kubernetes/options.env
ExecStart=/opt/bin/bootstrap-worker

[Install]
WantedBy=multi-user.target
EOF
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
  enable = false

  content = <<EOF
[Unit]
Description=KubernetesKubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
Requires=bootstrap.service
After=bootstrap.service

[Service]
EnvironmentFile=/run/metadata/coreos
EnvironmentFile=/etc/kubernetes/options.env
ExecStartPre=/opt/bin/kubelet-installer
ExecStartPre=/opt/bin/cni-installer
ExecStart=/opt/bin/kubelet \
  --api-servers=https://$${K8S_API} \
  --cluster-domain=cluster.local \
  --allow-privileged=true \
  --hostname-override=$${COREOS_EC2_IPV4_LOCAL} \
  --container-runtime=docker \
  --network-plugin=cni \
  --kubeconfig=/etc/kubernetes/secrets/kubelet.kubeconfig \
  --serialize-image-pulls=false \
  --register-schedulable=true \
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
  enable = false

  content = <<EOF
[Unit]
Description=KubernetesKubeProxy
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
Requires=bootstrap.service
After=bootstrap.service

[Service]
EnvironmentFile=/etc/kubernetes/options.env
ExecStartPre=/opt/bin/kubeproxy-installer
ExecStart=/opt/bin/kube-proxy \
  --cluster-cidr=$${K8S_POD_NETWORK} \
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
  name   = "flannel.service"
  enable = false

  content = <<EOF
[Unit]
Description=FlannelDaemon
Documentation=https://github.com/coreos/flannel
Requires=bootstrap.service
After=bootstrap.service

[Service]
EnvironmentFile=/run/metadata/coreos
EnvironmentFile=/etc/kubernetes/options.env
ExecStartPre=/opt/bin/flanneld-installer
ExecStartPre=/usr/bin/etcdctl \
  --endpoints=${join(",", var.etcd_nodes)} \
  set /flanneld/${var.cluster_name}/config '{"Network": "${var.pod_network}"}'
ExecStart=/opt/bin/flanneld \
  --iface=$${COREOS_EC2_IPV4_LOCAL} \
  --etcd-endpoints=$${K8S_ETCD_NODES} \
  --etcd-prefix=/flanneld/$${K8S_CLUSTER}
Restart=on-failure
RestartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "logger" {
  name   = "logger.service"
  enable = false

  content = <<EOF
[Unit]
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/docker stop logger.service
ExecStartPre=-/usr/bin/docker rm logger.service
ExecStart=/usr/bin/bash \
  -c '/usr/bin/journalctl -o short-iso -f | /usr/bin/docker run -i --name=logger.service coldog/awslogger -stream=$(hostname) -group=${var.cluster_name}'
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
  enable = false

  content = <<EOF
[Unit]
Description=KubernetesApiServer
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
Requires=bootstrap.service
After=bootstrap.service

[Service]
EnvironmentFile=/etc/kubernetes/options.env
ExecStartPre=-/usr/bin/docker stop apiserver.service
ExecStartPre=-/usr/bin/docker rm apiserver.service
ExecStart=/usr/bin/docker run --name=apiserver.service \
  -p 443:443 \
  -p 127.0.0.1:80:80 \
  -v /etc/kubernetes/secrets:/etc/kubernetes/secrets \
  quay.io/coreos/hyperkube:$${K8S_VERSION}_coreos.0 \
  /hyperkube \
  apiserver \
  --v=1 \
  --advertise-address=0.0.0.0 \
  --bind-address=0.0.0.0 \
  --secure-port=443 \
  --insecure-port=80 \
  --insecure-bind-address=0.0.0.0 \
  --service-cluster-ip-range=$${K8S_SERVICE_IP_RANGE} \
  --etcd-servers=$${K8S_ETCD_NODES} \
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
  enable = false

  content = <<EOF
[Unit]
Description=KubernetesControllerManager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
Requires=bootstrap.service
After=bootstrap.service

[Service]
EnvironmentFile=/etc/kubernetes/options.env
ExecStartPre=-/usr/bin/docker stop controllermanager.service
ExecStartPre=-/usr/bin/docker rm controllermanager.service
ExecStart=/usr/bin/docker run --name=controllermanager.service \
  -v /etc/kubernetes/secrets:/etc/kubernetes/secrets \
  quay.io/coreos/hyperkube:$${K8S_VERSION}_coreos.0 \
  /hyperkube \
  controller-manager \
  --address=0.0.0.0 \
  --allocate-node-cidrs=true \
  --cluster-cidr=$${K8S_POD_NETWORK} \
  --service-cluster-ip-range=$${K8S_SERVICE_IP_RANGE} \
  --kubeconfig=/etc/kubernetes/secrets/controller.kubeconfig \
  --cluster-name=$${K8S_CLUSTER} \
  --leader-elect=true \
  --root-ca-file=/etc/kubernetes/secrets/ca.pem \
  --v=2
ExecStop=/usr/bin/docker stop controllermanager.service

[Install]
WantedBy=multi-user.target
EOF
}

data "ignition_systemd_unit" "scheduler" {
  name   = "scheduler.service"
  enable = false

  content = <<EOF
[Unit]
Description=KubernetesScheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
Requires=bootstrap.service
After=bootstrap.service

[Service]
EnvironmentFile=/etc/kubernetes/options.env
ExecStartPre=-/usr/bin/docker stop scheduler.service
ExecStartPre=-/usr/bin/docker rm scheduler.service
ExecStart=/usr/bin/docker run --name=scheduler.service \
  -v /etc/kubernetes/secrets:/etc/kubernetes/secrets \
  quay.io/coreos/hyperkube:$${K8S_VERSION}_coreos.0 \
  /hyperkube \
  scheduler \
  --leader-elect=true \
  --kubeconfig=/etc/kubernetes/secrets/scheduler.kubeconfig \
  --v=2
ExecStop=/usr/bin/docker stop scheduler.service

[Install]
WantedBy=multi-user.target
EOF
}
