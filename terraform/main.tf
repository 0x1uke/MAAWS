provider "aws" {
  region  = var.region
  profile = var.profile
}

module "network" {
  source             = "./modules/network"
  tailscale_auth_key = var.tailscale_auth_key
  region             = var.region
  az                 = var.az
  key_pair           = var.key_pair
  universal_tags     = var.universal_tags
}

module "remnux" {
  source                  = "./modules/remnux"
  remnux_ami              = var.remnux_ami
  tailscale-subnet-router = module.network.security_group_id
  private_subnet          = module.network.private_subnet
  key_pair                = var.key_pair
  universal_tags          = var.universal_tags
}

module "flarevm" {
  source                  = "./modules/flarevm"
  flarevm_ami             = var.flarevm_ami
  tailscale-subnet-router = module.network.security_group_id
  private_subnet          = module.network.private_subnet
  key_pair                = var.key_pair
  universal_tags          = var.universal_tags
}
