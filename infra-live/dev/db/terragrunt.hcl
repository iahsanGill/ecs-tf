terraform {
  source = "tfr:///terraform-aws-modules/rds-aurora/aws?version=9.3.1"

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
  name                 = "main"
  engine               = "aurora-postgresql"
  engine_mode          = "provisioned"
  engine_version       = "14.5"
  storage_encrypted    = true
  master_username      = "root"
  database_name        = "chat"
  vpc_id               = dependency.vpc.outputs.vpc_id
  db_subnet_group_name = dependency.vpc.outputs.database_subnet_group_name
  monitoring_interval  = 60
  apply_immediately    = true
  skip_final_snapshot  = true
  instance_class       = "db.serverless"
  instances = {
    one = {}
    two = {}
  }
  serverlessv2_scaling_configuration = {
    min_capacity = 1
    max_capacity = 10
  }
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks
    }
  }
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                      = "vpc-12345678"
    database_subnet_group_name  = "default"
    private_subnets_cidr_blocks = ["192.198.16.0/20", "192.198.32.0/20"]
  }
}
