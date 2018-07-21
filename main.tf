provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.14.0"
  name    = "${var.cluster_name}"
  cidr    = "172.30.0.0/16"

  azs = [
    "${data.aws_availability_zones.available.names[0]}",
    "${data.aws_availability_zones.available.names[1]}",
    "${data.aws_availability_zones.available.names[2]}",
  ]

  private_subnets = ["172.30.1.0/24", "172.30.2.0/24", "172.30.3.0/24"]
  public_subnets  = ["172.30.4.0/24", "172.30.5.0/24", "172.30.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "${var.cluster_name}"
  }
}
