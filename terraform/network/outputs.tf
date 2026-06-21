output "vpc_id" {
  value = aws_vpc.vpc_lab1.id
}

output "subnets" {
  value = aws_subnet.subnets
}


output "vpc_cidr_block" {
  value = aws_vpc.vpc_lab1.cidr_block
}