output "alb_arn" {
  description = ""
  value       = aws_lb.this.arn
}

output "alb_zone_id" {
  description = ""
  value       = aws_lb.this.zone_id
}

output "http_listener_arn" {
  description = ""
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = ""
  value       = aws_lb_listener.https.arn
}
