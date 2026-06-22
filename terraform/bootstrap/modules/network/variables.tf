variable "vpc_cidr" {
  description = "CIDR block for the bootstrap VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "availability_zone" {
  description = "AZ to place the subnet in"
  type        = string
}