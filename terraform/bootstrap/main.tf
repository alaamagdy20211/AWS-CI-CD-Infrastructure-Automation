module "network" {
  source = "./modules/network"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
}

module "security" {
  source = "./modules/security"

  vpc_id           = module.network.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "ec2_controller" {
  source = "./modules/ec2-controller"

  subnet_id          = module.network.public_subnet_id
  security_group_id  = module.security.controller_sg_id
  key_name           = var.key_name
  instance_type      = var.controller_instance_type
}

module "ec2_agent" {
  source = "./modules/ec2-agent"

  subnet_id          = module.network.public_subnet_id
  security_group_id  = module.security.agent_sg_id
  key_name           = var.key_name
  instance_type      = var.agent_instance_type
}


# resource "local_file" "ansible_inventory" {
#   filename = "${path.module}/../../ansible/inventory.ini"
#   content = templatefile("${path.module}/templates/inventory.tpl", {
#     controller_ip = module.ec2_controller.controller_public_ip
#     agent_ip      = module.ec2_agent.agent_public_ip
#   })
# }

resource "local_file" "ssh_config" {
  filename = "${path.module}/../../ansible/ssh_config"
  content = templatefile("${path.module}/templates/ssh_config.tpl", {
    controller_ip = module.ec2_controller.controller_public_ip
    agent_ip      = module.ec2_agent.agent_public_ip
    key_name      = var.key_name
  })
}