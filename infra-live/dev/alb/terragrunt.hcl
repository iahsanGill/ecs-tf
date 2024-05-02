terraform {
  source = "../../../infra-modules/alb"
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
  vpc_id   = dependency.vpc.outputs.vpc_id
  alb_name = "${include.common.locals.project_name}-alb"
  subnets  = dependency.vpc.outputs.public_subnets
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id         = "vpc-12345678"
    public_subnets = ["subnet-12345678", "subnet-23456789"]
  }
}