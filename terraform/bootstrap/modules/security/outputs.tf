output "controller_sg_id" {
  value       = aws_security_group.controller.id
}

output "agent_sg_id" {
  value       = aws_security_group.agent.id
}