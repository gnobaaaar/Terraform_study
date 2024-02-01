provider "aws" {
  region = "ap-northeast-3"
}

resource "aws_instance" "dw-ubuntu" {
    ami = "ami-0e4f85d0d7c4869ba"
    instance_type = "t2.micro"
}

