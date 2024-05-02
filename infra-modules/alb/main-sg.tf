locals {
  all_ips      = "0.0.0.0/0"
  tcp_protocol = "tcp"
  any_protocol = "-1"
  any_port     = 0
  http_port    = 80
  https_port   = 443
}

resource "aws_security_group" "this" {
  name        = "${var.alb_name}-alb-sg"
  description = "LoadBalancer Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = [local.all_ips]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = local.https_port
    to_port     = local.https_port
    protocol    = local.http_port
    cidr_blocks = [local.all_ips]
  }

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = [local.all_ips]
  }
}
