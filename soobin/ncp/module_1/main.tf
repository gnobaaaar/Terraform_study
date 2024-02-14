terraform {
    required_providers {
        ncloud = {
            source = "navercloudplatform/ncloud"
        }
    }
    required_version = ">= 0.13"
}
provider "ncloud" {
    support_vpc = true
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
}
module "network" {
  source  = "./network_module"

}
module "server" {
  source  = "./server_module"
  vpc_no = module.network.vpc_no
  sunbet_public_id = module.network.subnet_public_id

}