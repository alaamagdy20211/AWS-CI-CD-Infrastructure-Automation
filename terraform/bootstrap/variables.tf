variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.10.1.0/24"
}

variable "availability_zone" {
  type        = string
  default     = "us-east-1a"
}

variable "key_name" {
  type        = string
  default = "pk_project_ec2"
}

variable "controller_instance_type" {
  type        = string
  default     = "c7i-flex.large"
}

variable "agent_instance_type" {
  type        = string
  default     = "c7i-flex.large"
}

variable "allowed_ssh_cidr" {
  type        = string
  default     = "0.0.0.0/0"
}