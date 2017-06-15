provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "state.coldog.xyz"
    key    = "default.tfstate"
    region = "us-west-2"
  }
}

module "cluster" {
  source = "../../cluster"

  base_domain  = "coldog.xyz"
  cluster_name = "default"
  vault_addr   = "https://vault.coldog.xyz"
}
