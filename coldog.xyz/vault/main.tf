provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "coldog-tfstate"
    key    = "vault.tfstate"
    region = "us-west-2"
  }
}

module "vault" {
  source = "../../vault"

  bucket   = "coldog-vault"
  domain   = "coldog.xyz"
  dns_name = "vault"

  instance_type = "t2.micro"
  instances = 1
  container_image = "vault:latest"
}

output "instance_ips" {
  value = ["${module.vault.instance_ips}"]
}

output "vault_host" {
  value = "${module.vault.vault_host}"
}