output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}