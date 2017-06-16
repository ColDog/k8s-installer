provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "coldog-tfstate"
    key    = "default.tfstate"
    region = "us-west-2"
  }
}

module "cluster" {
  source = "../../cluster"

  base_domain  = "coldog.xyz"
  cluster_name = "k8default"
  vault_addr   = "https://vault.coldog.xyz"
  asset_bucket = "coldog-cluster-assets"
}
