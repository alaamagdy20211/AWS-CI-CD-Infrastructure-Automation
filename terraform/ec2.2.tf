resource "aws_instance" "application" {
ami = var.ami
instance_type = var.instance_type
  subnet_id = module.network.subnets["priv_subnet_1"].id
  vpc_security_group_ids = [aws_security_group.allow_traffic_limited.id]
  provisioner "local-exec"{
  command = "echo ${self.private_ip} > ec2_private_ip.txt"
}
}