variable "region" {
  default = "KR"
}
variable "zones" {
  default =  "KR-2"
}
variable name_terra {
  default = "dw-server"
}
variable "login_key_name" {
  default = "dw-key"
}
variable "vpc_no" {
  description = "vpc number"
  #type = number
}
variable "sunbet_public_id" {
  description = "public subnet id"
  #type = number
}
# data filter를 사용하지 않을 경우 이미지 및 스펙 코드 명시
# variable "server_image_product_code" {
#   default = "SW.VSVR.OS.LNX64.CNTOS.0708.B050"
# }
# # HDD : CPU 2 ,Memory 4GB , Disk 50GB
# variable "server_product_code" {
#   default = "SVR.VSVR.HICPU.C002.M004.NET.HDD.B050.G002"
# }