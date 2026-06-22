resource "aws_instance" "bastion" {
ami = var.ami
instance_type = var.instance_type
subnet_id = module.network.subnets["public_subnet_1"].id
vpc_security_group_ids = [var.bastion_sg_id]
associate_public_ip_address = true      
provisioner "local-exec"{
  command = "echo ${self.public_ip} > ip_bastion.txt"
}
}


resource "aws_instance" "application" {
ami = var.ami
instance_type = var.instance_type
  subnet_id = module.network.subnets["priv_subnet_1"].id
  vpc_security_group_ids = [var.app_sg_id]
  provisioner "local-exec"{
  command = "echo ${self.private_ip} > ec2_private_ip.txt"
}
}