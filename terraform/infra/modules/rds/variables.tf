variable "vpc_id"{
    type=string
}
variable "subnet_ids"{
  type = list(string)
  }
  variable "vpc_cidr"{
    type=string
  }


# should add app_sg_id 
variable "app_sg_id" {
  type = string
}


# for improvment
# variable "db_username" {
  
# }
# variable "db_username" {
  
# }
# variable "db_instance_class" {
  
# }
# variable "allocated_storage" {
  
# }

