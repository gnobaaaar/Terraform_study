# Login Key 키페어 생성
resource "ncloud_login_key" "bastion_server_key" {
    key_name = "${var.name_terra}-bastion-svr-key"
    /*Attributes Reference
    ncloud_login_key.bastion_server_key.private_key
    */
}
resource "local_file" "ncp_pem" {
  filename = "${ncloud_login_key.bastion_server_key.key_name}.pem"
  content = ncloud_login_key.bastion_server_key.private_key
}
# #Init script(optional)
# resource "ncloud_init_script" "init_script_httpd_install" {
#   name    = "httpd-install"
#   content = "#!/bin/bash\nyum -y install httpd\nsystemctl enable --now httpd\necho $HOSTNAME >> /var/www/html/index.html"
# }

#ACG
resource "ncloud_access_control_group" "bastion_acg_01" {
  name        = "${var.name_terra}-acg01"
  description = "${var.name_terra} Access controle group"
  vpc_no      = var.vpc_no # ncloud_vpc.vpc.id
}
resource "ncloud_access_control_group_rule" "bastion_acg_rule_01" {
  access_control_group_no = ncloud_access_control_group.bastion_acg_01.id
  
  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "22"
    description = "accept 22 port(all ip)"
  }
  outbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0" 
    port_range  = "1-65535"
    description = "accept TCP 1-65535 port"
  }
  outbound {
    protocol    = "UDP"
    ip_block    = "0.0.0.0/0" 
    port_range  = "1-65535"
    description = "accept UDP 1-65535 port"
  }
  outbound {
    protocol    = "ICMP"
    ip_block    = "0.0.0.0/0" 
    description = "accept ICMP"
  }
}
#NIC
resource "ncloud_network_interface" "nic_bastion" {
  #count = "1"
  name                  = "${var.name_terra}-bastion-nic"
  subnet_no             = var.sunbet_public_id
  #private_ip            = var.bastion
  access_control_groups = [ncloud_access_control_group.bastion_acg_01.id]
  /*Attributes Reference
    ncloud_network_interface.nic_bastion.id
  */
}
# Block storage (optional)
# resource "ncloud_block_storage" "block_storage" {
#     server_instance_no = ncloud_server.bastion_server.instance_no
#     name = "${ncloud_server.bastion_server.name}-blk01"
#     size = "2000"
# }
# Server - bastion server
resource "ncloud_server" "bastion_server" {
    subnet_no = var.sunbet_public_id
    # ncloud_subnet.subnet_public.id
    name = "${var.name_terra}-bastion-svr"
    server_image_product_code = data.ncloud_server_image.server_image.id
    server_product_code = data.ncloud_server_product.product.id
    login_key_name = ncloud_login_key.bastion_server_key.key_name
    network_interface   {
      network_interface_no = ncloud_network_interface.nic_bastion.id
      order = 0
  }
    #VPC에서는 서버 생성 시 ACG 설정을 지원하지 않으므로 acg가 할당된 nic 연결 필요
    /*Attributes Reference
    ncloud_server.bastion_server.instance_no
    */
}
#Server Image Type & Product Type
data "ncloud_server_image" "server_image" {
  filter {
    name = "product_name"
    # values = ["ubuntu-20.04"]
    values = ["Rocky Linux 8.8"]
  }
  /* image list
   + "SW.VSVR.OS.LNX64.CNTOS.0703.B050"          = "centos-7.3-64"
   + "SW.VSVR.OS.LNX64.CNTOS.0708.B050"          = "CentOS 7.8 (64-bit)"
   + "SW.VSVR.OS.LNX64.UBNTU.SVR1604.B050"         = "ubuntu-16.04-64-server"
   + "SW.VSVR.OS.LNX64.UBNTU.SVR1804.B050"         = "ubuntu-18.04"
   + "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"         = "ubuntu-20.04"
   + "SW.VSVR.OS.WND64.WND.SVR2016EN.B100"         = "Windows Server 2016 (64-bit) English Edition"
   + "SW.VSVR.OS.WND64.WND.SVR2019EN.B100"         = "Windows Server 2019 (64-bit) English Edition"
  */
  /* Attributes Reference
    data.ncloud_server_image.server_image.id
  */
}
data "ncloud_server_product" "product" {
  server_image_product_code = data.ncloud_server_image.server_image.id

  filter {
    name   = "product_code"
    values = ["SSD"]
    regex = true
  }
  filter {
    name   = "cpu_count"
    values = ["2"]
  }
  filter {
    name   = "memory_size"
    values = ["4GB"]
  }
  filter {
    name   = "product_type"
    values = ["HICPU"]
    /* Server Spec Type
    STAND
    HICPU
    HIMEM
    */
  }
  /* Attributes Reference
    data.ncloud_server_product.product.id
  */
}

# Export Root Password
data "ncloud_root_password" "default" {
  server_instance_no = ncloud_server.bastion_server.instance_no # ${ncloud_server.vm.id}
  private_key = ncloud_login_key.bastion_server_key.private_key # ${ncloud_login_key.key.private_key}
  /*Attributes Reference
    ncloud_root_password.default.root_password
  */
}
resource "local_file" "bastion_svr_root_pw" {
  filename = "${ncloud_server.bastion_server.name}-root_password.txt"
  content = "${ncloud_server.bastion_server.name} => ${data.ncloud_root_password.default.root_password}"
}
# Public IP
resource "ncloud_public_ip" "public_ip" {
  server_instance_no = ncloud_server.bastion_server.id
  description        = "for ${ncloud_server.bastion_server.name} public ip"
}