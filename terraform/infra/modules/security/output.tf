output "bastion_sg_id" {
  value = aws_security_group.allow_traffic.id

}

output "app_sg_id" {
  value = aws_security_group.allow_traffic_limited.id
}
