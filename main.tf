provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "state.default.coldog.xyz"
    key    = "cluster-state"
    region = "us-west-2"
  }
}

module "cluster" {
  source = "./cluster"

  dns_zone_id  = "Z3FHNMGH8LFH0Q"
  base_domain  = "coldog.xyz"
  state_bucket = "state.default.coldog.xyz"
  cluster_name = "default"
  vault_addr   = "vault.coldog.xyz"
}

module "vault" {
  source = "./vault"

  bucket      = "vault.coldog.xyz"
  dns_zone_id = "Z3FHNMGH8LFH0Q"
  domain      = "coldog.xyz"
}

//output "api_server" {
//  value = "${module.cluster.api_server}"
//}
