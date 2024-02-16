variable "access_key" { 
    default = "BO5UggY14DcvqcPZ8bLM"
}

variable "secret_key" { 
    default = "XSoH2S2YLO6jr26GDTgsqV1xYBKDo1qOwKsqir75"
}

variable "region" {
  default = "KR"
}

variable "zones" {
  default =  "KR-2"
}

variable "server_image_product_code" { # centos-7.3-64
  default = "SPSW0LINUX000046"
}

variable "server_product_code" { # vCPU 2EA, Memory 2GB, Disk 50GB
  default = "SPSVRSTAND000003" 
}
variable "login_key_name" {
  default = "terra-key"
}

variable name_terra {
  default = "dw-server"
}