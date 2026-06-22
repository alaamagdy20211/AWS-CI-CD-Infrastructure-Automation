output "agent_public_ip" {
  value       = aws_instance.agent.public_ip
}

output "agent_private_ip" {
  value       = aws_instance.agent.private_ip
}

output "agent_instance_id" {
  value       = aws_instance.agent.id
}