variable "vpc_name" {
  type    = "string"
  default = "default"
}

variable "cidr_blocks" {
  type = "list"

  default = [
    "10.0.0.0/24",
    "10.1.0.0/24",
    "10.2.0.0/24",
  ]
}
