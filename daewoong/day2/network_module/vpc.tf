#VPC
resource "ncloud_vpc" "vpc" {
name = "${var.name_terra}-vpc"
ipv4_cidr_block = var.vpc_cidr
}


/*Attributes Reference

ncloud_vpc.vpc.vpc_no
ncloud_vpc.vpc.ipv4_cidr_block
ncloud_vpc.vpc.default_network_acl_no

*/