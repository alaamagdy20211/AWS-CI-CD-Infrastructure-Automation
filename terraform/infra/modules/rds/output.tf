output "rds_endpoint" {
    value = aws_db_instance.wp_rds.endpoint
  
}
output "rds_port" {
  value = aws_db_instance.wp_rds.port
}