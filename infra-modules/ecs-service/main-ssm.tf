resource "aws_ssm_parameter" "rds_host" {
  name        = "/rds/host"
  description = "RDS host"
  type        = "SecureString"
  value       = var.rds_host_value
}

resource "aws_ssm_parameter" "rds_database_name" {
  name        = "/rds/name"
  description = "RDS database name"
  type        = "SecureString"
  value       = var.rds_database_name_value
}
