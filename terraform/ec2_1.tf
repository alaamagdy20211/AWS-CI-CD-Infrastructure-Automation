resource "aws_instance" "bastion" {
ami = var.ami
instance_type = var.instance_type
subnet_id = module.network.subnets["public_subnet_1"].id
vpc_security_group_ids = [aws_security_group.allow_trafficc.id]
associate_public_ip_address = true      
provisioner "local-exec"{
  command = "echo ${self.public_ip} > ip_bastion.txt"
}
}