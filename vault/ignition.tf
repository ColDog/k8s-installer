data "ignition_config" "vault" {
  systemd = [
    "${data.ignition_systemd_unit.vault.id}",
  ]

  files = [
    "${data.ignition_file.vault_config.id}",
  ]
}

data "ignition_systemd_unit" "vault" {
  name   = "vault.service"
  enable = true

  content = <<EOF
[Unit]
Description=Vault
Documentation=https://www.vaultproject.io
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/docker stop vault.service
ExecStartPre=-/usr/bin/docker rm vault.service
ExecStart=/usr/bin/docker run \
  -v /etc/vault:/etc/vault/ \
  --name=vault.service \
  --privileged \
  -p 80:8200 \
  vault:latest \
  vault server -config=/etc/vault/config.hcl
ExecStop=/usr/bin/docker stop vault.service
Restart=on-failure
RestartSec=15
Restart=always

[Install]
WantedBy=multi-user.target
EOF
}

data "aws_region" "current" {
  current = true
}

data "ignition_file" "vault_config" {
  filesystem = "root"
  path       = "/etc/vault/config.hcl"
  mode       = 0644

  content {
    content = <<EOF
storage "s3" {
  bucket = "${var.bucket}"
  region = "${data.aws_region.current.name}"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
EOF
  }
}
