
module "network" {
    source = "./modules/network"
    vpc_icdr = var.vpc_icdr
    subnets = var.subnets
}

module "security" {
    source = "./modules/security"
    vpc_cidr_block = module.network.vpc_cidr_block
    vpc_id = module.network.vpc_id
  
}

module "ec2" {
    source = "./modules/ec2"
    bastion_sg_id = module.security.bastion_sg_id
    app_sg_id = module.security.app_sg_id
    instance_type =  var.instance_type   
    subnets = module.network.subnets
    key_name = var.key_name
}

module "ses" {
    source = "./modules/ses"
  
}


module "rds" {
    source = "./modules/rds"
    vpc_id = module.network.vpc_id
    subnet_ids = [module.network.subnets["priv_subnet_1"].id ,module.network.subnets["priv_subnet_2"].id ]
    vpc_cidr = module.network.vpc_cidr_block
    app_sg_id = module.security.app_sg_id

}
module "redis" {
    source = "./modules/redis"
    subnet_ids = [module.network.subnets["priv_subnet_1"].id ,module.network.subnets["priv_subnet_2"].id ]
    vpc_cidr = module.network.vpc_cidr_block
    vpc_id = module.network.vpc_id
    app_sg_id = module.security.app_sg_id
}

module "notifications" {
    source = "./modules/notifications"
    recipient_email = "alaa.magdy.abdelrahman@gmail.com"
    sender_email = "alaamagdy3008@gmail.com"
    region = var.region
  
}

module "alb" {
  source = "./modules/alb"
  app_id = module.ec2.app_id
  app_sg_id = module.security.app_sg_id
  subnets = module.network.subnets
  vpc_id = module.network.vpc_id

}

resource "local_file" "infra_ssh_config" {
  filename = "${path.module}/../../ansible/inventory/ssh_config_infra"
  content = templatefile("${path.module}/templates/ssh_config.tpl", {
    bastion_public_ip = module.ec2.bastion_public_ip
    app_private_ip    = module.ec2.app_private_ip
    key_name           = var.key_name                     
  })
}

resource "local_file" "inventory" {
  filename = "${path.module}/../../ansible/inventory/infra.ini"
  content = templatefile("${path.module}/templates/inventory.tpl", {
    bastion_public_ip = module.ec2.bastion_public_ip
    app_private_ip    = module.ec2.app_private_ip
    key_name           = var.key_name                     
  })
}