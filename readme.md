# Kubernetes Installer

## Getting Started

### Install

- `brew install kubernetes-cli`
- `brew install jq`
- `brew install vault`

### Requirements

- A Publicly available DNS Zone on AWS.
- An ACM certificate registered for the given zone.
- An accessible SSH

### 1. Setup Vault

1. Create a folder `mkdir ./vault` to hold your terraform configuration.
2. Copy the following configuration into `./vault/main.tf`:

```bash
cat > ./vault/main.tf <<EOF
provider "aws" {
  region = "us-west-2"
}

module "vault" {
  source = "github.com/ColDog/k8s-installer/vault"

  bucket   = "vault-secrets"
  domain   = "example.com"
  dns_name = "vault"
  ssh_key  = "my_ssh"
}
EOF
```

3. Run `terraform apply`.
4. Unseal vault, to do this you must ssh into the machine and follow the unseal steps: https://www.vaultproject.io/docs/concepts/seal.html.
5. Set the `VAULT_ADDR` environment variable in your terminal and ensure you are authorized to access vault through the cli.

### 2. Setup Cluster

1. Create a folder `mkdir ./default` to hold your terraform configuration.
2. Copy the following configuration into `./default/main.tf`:

```bash
cat > ./default/main.tf <<EOF
provider "aws" {
  region = "us-west-2"
}

module "cluster" {
  source = "../../cluster"

  dns_zone_id  = "Z3FHNMGH8LFH0Q"
  base_domain  = "coldog.xyz"
  cluster_name = "default"
  vault_addr   = "https://vault.coldog.xyz"
}
EOF
```