module "network" {
    source = "./network"
    vpc_icdr = var.vpc_icdr
    subnets = var.subnets
}

module "rds" {
    source = "./rds"
    vpc_id = module.network.vpc_id
    subnet_ids = [module.network.subnets["priv_subnet_1"].id ,module.network.subnets["priv_subnet_2"].id ]
    vpc_cidr = module.network.vpc_cidr_block


}
module "redis" {
    source = "./redis"
    subnet_ids = [module.network.subnets["priv_subnet_1"].id ,module.network.subnets["priv_subnet_2"].id ]
    vpc_cidr = module.network.vpc_cidr_block
    vpc_id = module.network.vpc_id


}