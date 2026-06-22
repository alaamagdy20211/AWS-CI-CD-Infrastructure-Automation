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