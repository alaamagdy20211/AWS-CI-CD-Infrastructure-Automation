
variable "subnet_ids" {
    type=list(string)
}
variable "vpc_cidr"{
    type=string
}

variable "vpc_id"{
    type=string
}

variable "app_sg_id" {
    type = string
  
}

# for improvment
# node_type
# num_cache_nodes