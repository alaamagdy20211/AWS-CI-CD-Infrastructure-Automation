output "vpc_id" {
  value       = aws_vpc.bootstrap.id
}

output "vpc_cidr_block" {
  value       = aws_vpc.bootstrap.cidr_block
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
}