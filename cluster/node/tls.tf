data "ignition_file" "tls_provisioner" {
  path       = "/opt/bin/tls-provisioner"
  mode       = 0700
  filesystem = "root"

  content {
    content = <<EOF
#!/usr/bin/bash
# Usage: tls-provisioner [name] [common-name]

# TODO: Get vault stuff.
/usr/bin/vault write -format=json pki/issue/"$1" common_name="$2"
EOF
  }
}
