resource "aws_cloudwatch_log_group" "this" {
  name              = local.log_group_name
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.service_name
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.ecs_task_exec_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = "${aws_ecr_repository.this.repository_url}:latest"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region"        = var.aws_region
          "awslogs-group"         = local.log_group_name
          "awslogs-stream-prefix" = local.container_name
        }
      }
      environment = [
        {
          name  = "PORT",
          value = "8080"
        }
      ]
      secrets = [
        {
          name      = "RDB_HOST",
          valueFrom = aws_ssm_parameter.rds_host.arn
        },
        {
          name      = "DB_NAME",
          valueFrom = aws_ssm_parameter.rds_database_name.arn
        },
        {
          name      = "RDS_CREDENTIALS",
          valueFrom = var.rds_secret_arn
        }
      ]
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 8080
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = local.service_name
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  depends_on      = [aws_lb_target_group.this]
  launch_type     = "FARGATE"

  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  enable_ecs_managed_tags            = false
  enable_execute_command             = true

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = false
    security_groups  = var.security_groups
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = local.container_name
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

# 
# AutoScaling
# 
resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.asg_max_capacity
  min_capacity       = var.asg_min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${local.service_name}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.asg_cpu_target_value
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "memory" {
  name               = "${local.service_name}-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.asg_memory_target_value
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
