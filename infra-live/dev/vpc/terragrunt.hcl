terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.8.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "common" {
  path           = find_in_parent_folders("common.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  name               = "${include.common.locals.project_name}-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets   = ["10.0.201.0/24", "10.0.202.0/24"]
  enable_ipv6        = false
  enable_nat_gateway = true
  single_nat_gateway = false
  vpc_tags           = { Name = "${include.common.locals.project_name}-vpc" }
}
