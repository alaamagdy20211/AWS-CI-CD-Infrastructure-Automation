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

