provider "ncloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "random_id" "id" {
  byte_length = 4
}

resource "ncloud_login_key" "key" {
  key_name = var.login_key_name
}

# 로컬파일로 저장
resource "local_file" "ncp_pem" {
  filename = "${ncloud_login_key.key.key_name}.pem"
  content = ncloud_login_key.key.private_key
}

data "ncloud_root_password" "rootpwd" {
  server_instance_no        = ncloud_server.server.id
  private_key               = ncloud_login_key.key.private_key
}

resource "ncloud_server" "server" {  
  name                        = var.name_terra
  server_image_product_code   = var.server_image_product_code
  server_product_code         = var.server_product_code
  login_key_name              = ncloud_login_key.key.key_name
  zone                                          = var.zones
}


# 루트 패스워드를 추출
data "ncloud_root_password" "default" {
  server_instance_no = ncloud_server.server.instance_no # ${ncloud_server.vm.id}
  private_key = ncloud_login_key.key.private_key # ${ncloud_login_key.key.private_key}
  /*Attributes Reference
    ncloud_root_password.default.root_password
  */
}
# 루트 패스워드를 파일로 저장
resource "local_file" "bastion_svr_root_pw" {
  filename = "${ncloud_server.server.name}-root_password.txt"
  content = "${ncloud_server.server.name} => ${data.ncloud_root_password.default.root_password}"
}
# Public IP
resource "ncloud_public_ip" "public_ip" {
  server_instance_no = ncloud_server.server.id
  description        = "for ${ncloud_server.server.name} public ip"
}