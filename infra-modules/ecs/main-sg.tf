locals {
  all_ips      = "0.0.0.0/0"
  any_protocol = "-1"
  any_port     = 0
}

resource "aws_security_group" "ecs" {
  name   = "${var.ecs_cluster_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = [local.all_ips]
  }
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = [local.all_ips]
  }
}
