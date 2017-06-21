# Kubernetes Installer

## Features

- Cluster certificates signed by and stored in vault.
- Control plane in an autoscaling group with Healthchecks.
- Configurable, uses Coreos ignition configuration for provisioning.
- Built for security and high availability.

## Future Work

- Teardown scripts, remove vault certs for deleted nodes.
- Highly available and configurable vault backends.
- Calico networking plugin.

## Overview

### Control Plane

The Kubernetes control plane is created inside a master autoscaling group. This group can be scaled up and down dynamically. Additionally, the autoscaling healthchecks are connected directly to the Kubernetes api server. If an api server is failing it will be replaced by the autoscaling group.

### Vault

Vault provides all of the certificates to each component of the cluster including local `kubeconfig` objects. Upon boot, each node will request the certificates it needs from vault. Authorization is handled through the vault aws-ec2 backend which allows vault to distinguish between worker nodes and master nodes. Worker nodes may create credentials for kubeproxy and kubelet services, whereas master nodes can create credentials for any user.

Vault can also provide credentials for local users that have access to vault. An example of this is provided in the `scripts/vault/create-user` and `scripts/vault/get-kubeconfig` files.

The cluster creation process involves setting up a vault `pki` backend and specific roles for the master and worker instances. This can be configured and this step handled externally.

All vault certificates are only valid for 720 hours at the moment. This means you must cycle machines about once a month.

## Getting Started

### Install

- `brew install kubernetes-cli`
- `brew install jq`
- `brew install vault`

### Requirements

- A Publicly available DNS Zone on AWS.
- An ACM certificate registered for the given zone.
- An accessible SSH Key

### 1. Setup Vault

This step involves setting up a vault instance to issue ssh keys and other credentials to our Kubernetes cluster. This step is not needed if you already have a running vault cluster. All the Kubernetes installer needs is access to vault through the `vault` cli on the machine that you run the terraform scripts. The following steps will set up a basic vault installation.

1. Create a folder `mkdir ./vault` to hold your terraform configuration.
2. Create an s3 bucket to hold configuration.
3. Copy the following configuration into `./vault/main.tf` and replace the relevant variables.

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
  ssh_key  = "my_ssh_key"
}
EOF
```

4. Run `terraform apply`.
5. Unseal vault, to do this you must ssh into the machine and follow the unseal steps: https://www.vaultproject.io/docs/concepts/seal.html.
6. Set the `VAULT_ADDR` and `VAULT_TOKEN` environment variables in your terminal and ensure you are authorized to access vault through the cli. Try running `vault mounts` to see if the vault CLI is configured.
7. Run `vault auth-enable aws-ec2`. We need the aws-ec2 auth backend enabled for Vault.

### 2. Setup Cluster Assets

The cluster assets S3 bucket is an S3 bucket that is accessible to the Kubernetes cluster through an AWS VPC Endpoint. It provides the static binaries needed to run the core pieces of infrastructure. This bucket cannot be shared between clusters at the moment, but the goal is for this to be a shared resource.

1. Create a folder `mkdir ./assets` to hold basic asset configuration.
2. Create an s3 bucket.
3. Copy the following configuration into `./assets/main.tf`:

```bash
cat > ./vault/main.tf <<EOF
provider "aws" {
  region = "us-west-2"
}

module "assets" {
  source = "../../assets"
  bucket = "my_bucket"
}
EOF
```

4. Run `terraform apply`.


### 2. Setup Cluster

1. Create a folder `mkdir ./k8s-cluster` to hold your terraform configuration.
2. Copy the following configuration into `./k8s-cluster/main.tf`:

```bash
cat > ./k8s-cluster/main.tf <<EOF
provider "aws" {
  region = "us-west-2"
}

module "cluster" {
  source = "../../cluster"

  base_domain  = "coldog.xyz"
  cluster_name = "default"
  vault_addr   = "https://vault.my-domain.xyz"
}
EOF
```

3. `terraform apply`

