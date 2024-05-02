# ALB target group for ECS
resource "aws_lb_target_group" "this" {
  name        = "${var.ecs_cluster_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    matcher             = "200-499"
    interval            = 300
    timeout             = 60
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.https_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = ["*"]
    }
  }
}
