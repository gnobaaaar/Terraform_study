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

data "ncloud_root_password" "rootpwd" {
  count                     = "2"
  server_instance_no        = ncloud_server.server[count.index].id
  private_key               = ncloud_login_key.key.private_key
}

data "ncloud_port_forwarding_rules" "rules" {
  count                    = "2"
  zone                     = ncloud_server.server[count.index].zone
}


resource "ncloud_server" "server" {
  count                       = "2"     
  name                        = "ncloud-terraform-test-vm-${count.index+1}"
  server_image_product_code   = var.server_image_product_code
  server_product_code         = var.server_product_code
  description                 = "ncloud-terraform-test-vm-${count.index+1} is best tip!!"
  login_key_name              = ncloud_login_key.key.key_name
  access_control_group_configuration_no_list    = ["333376"]
  zone                                          = var.zones
 
}


resource "null_resource" "ssh" {
 count = "2"
 connection {
    type     = "ssh"
    host     = ncloud_port_forwarding_rule.forwarding[count.index].port_forwarding_public_ip 
    user     = "root"
    port     = var.port_forwarding_external_port[count.index]
    password = data.ncloud_root_password.rootpwd[count.index].root_password
  }

  provisioner "remote-exec" {
    script = "./httpd_install.sh"
  }
}


resource "ncloud_port_forwarding_rule" "forwarding" {
  count                            = "2"
  port_forwarding_configuration_no = data.ncloud_port_forwarding_rules.rules[count.index].id
  server_instance_no               = ncloud_server.server[count.index].id
  port_forwarding_external_port    = var.port_forwarding_external_port[count.index]
  port_forwarding_internal_port    = "22"
}

resource "ncloud_load_balancer" "lb" {
  name                             = "jslee-LB"
  algorithm_type                   = "RR"
  description                      = "ncloud-terraform-test-lb is best!!"

  rule_list {
    protocol_type        = "HTTP"
    load_balancer_port   = 80
    server_port          = 80
    l7_health_check_path = "/"
  }

  server_instance_no_list = [ncloud_server.server[0].id, ncloud_server.server[1].id]
  internet_line_type      = "PUBLC"
  network_usage_type      = "PBLIP"
  region                  = "KR"
}