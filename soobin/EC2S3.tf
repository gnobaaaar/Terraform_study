/* provider "aws" {
    region = "ap-northeast-2"
}

#EC2설정
resource "aws_instance" "SB_instance" {
    ami = "ami-0bc4327f3aabf5b71"
    instance_type = "t2.micro"
    subnet_id= "aws_subnet.SB_subnet"
    key_name = "soobin"
    iam_instance_profile = "aws_iam_instance_profile.SB_instance_profile"
    vpc_security_group_ids = [aws_security_group.SB_security_group]

    tags = {
        Name = "SB_instance"
    }
  
}

#S3설정
resource "aws_s3_bucket" "SB_bucket" {
    bucket = "SB_bucket"
    #acl = "public-read-write"
      # `private`, `public-read`, `public-read-write`, `aws-exec-read`, `authenticated-read`, `log-delivery-write` 중 하나 선택. 
  # 기본값은 `private`.
  # `grant`와 대비되는 속성
}
*/