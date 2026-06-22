output "controller_public_ip" {
  value       = aws_instance.controller.public_ip
}

output "controller_private_ip" {
  value       = aws_instance.controller.private_ip
}

output "controller_instance_id" {
  value       = aws_instance.controller.id
}