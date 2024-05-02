terraform {
  source = "../../../infra-modules/ecs-service"
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
  vpc_id                  = dependency.vpc.outputs.vpc_id
  subnets                 = dependency.vpc.outputs.private_subnets
  alb_arn                 = dependency.alb.outputs.alb_arn
  alb_zone_id             = dependency.alb.outputs.alb_zone_id
  http_listener_arn       = dependency.alb.outputs.http_listener_arn
  https_listener_arn      = dependency.alb.outputs.https_listener_arn
  cpu                     = 512
  memory                  = 1024
  asg_min_capacity        = 1
  asg_max_capacity        = 2
  asg_cpu_target_value    = 40
  asg_memory_target_value = 40
  ecs_cluster_name        = "${include.common.locals.project_name}-ecs-cluster"
  ecs_cluster_arn         = dependency.ecs.outputs.ecs_cluster_arn
  ecs_task_exec_role_arn  = dependency.ecs.outputs.ecs_task_exec_role_arn
  ecs_task_role_arn       = dependency.ecs.outputs.ecs_task_role_arn
  security_groups         = [dependency.ecs.outputs.security_group_id]
  rds_secred_arn          = dependency.rds_aurora.outputs.cluster_master_user_secret[0].secret_arn
  rds_host_value          = dependency.rds_aurora.outputs.cluster_endpoint
  rds_database_name_value = dependency.rds_aurora.outputs.cluster_database_name

  name       = "chat"
  aws_region = "us-east-1"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id          = "vpc-12345678"
    private_subnets = ["subnet-12345678", "subnet-23456789"]
  }
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs = {
    alb_arn            = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/1234567890123456"
    alb_zone_id        = "Z12345678901234567890"
    http_listener_arn  = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/1234567890123456/1234567890123456"
    https_listener_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/my-alb/1234567890123456/1234567890123456"
  }
}

dependency "ecs" {
  config_path = "../ecs"

  mock_outputs = {
    ecs_cluster_arn        = "arn:aws:ecs:us-east-1:123456789012:cluster/my-ecs-cluster"
    security_group_id      = "sg-12345678"
    ecs_task_exec_role_arn = "arn:aws:iam::123456789012:role/my-ecs-task-exec-role"
    ecs_task_role_arn      = "arn:aws:iam::123456789012:role/my-ecs-task-role"
  }
}

dependency "rds_aurora" {
  config_path = "../db"

  mock_outputs = {
    cluster_master_user_secret = [
      {
        secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-cluster-master-user-secret-123456"
      }
    ]
    cluster_endpoint      = "my-cluster.cluster-123456789012.us-east-1.rds.amazonaws.com"
    cluster_database_name = "chat"
  }
}
