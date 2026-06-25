data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami                          = data.aws_ami.ubuntu.id
  instance_type                = var.instance_type
  subnet_id                    = var.subnets["public_subnet_1"].id
  vpc_security_group_ids       = [var.bastion_sg_id]
  associate_public_ip_address  = true
  key_name                     = var.key_name

  tags = {
    Name = "bastion"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ip_bastion.txt"
  }
}

resource "aws_instance" "app" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = var.subnets["priv_subnet_2"].id
  vpc_security_group_ids  = [var.app_sg_id]
  key_name                = var.key_name

  tags = {
    Name = "app-server"
  }

  provisioner "local-exec" {
    command = "echo ${self.private_ip} > ec2_private_ip.txt"
  }
}