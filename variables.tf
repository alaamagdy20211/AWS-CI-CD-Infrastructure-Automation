variable "region" {
    type=string
}
variable "ami" {
    type=string
}
variable "instance_type" {
    type=string
}
variable "vpc_icdr" {
    type = string 
}

variable "subnets" {
 type = list(object({
    name=string
    cidr=string
    type=string
    az=string

 }))  
}