/*provider "aws" {
    region = "ap-northeast-2"
}
*/

#신규 VPC 생성
resource "aws_vpc" "SB_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
      Name = "SB_vpc"
    }
}

#신규 서브넷 생성
resource "aws_subnet" "SB_subnet" {
  vpc_id = aws_vpc.SB_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "SB_subnet"
  }
}

#신규 IGW 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.SB_vpc.id
  tags = {
    Name = "main"
  }
}

#라우팅테이블생성
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.SB_vpc.id

}

resource "aws_route_table_association" "route_table_1" {
  subnet_id      = aws_subnet.SB_subnet.id
  route_table_id = aws_route_table.route_table.id
}

# route 규칙 추가
resource "aws_route" "sbdefaultroute" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#신규 보안그룹 생성
resource "aws_security_group" "SB_security_group" {
  name = "SB_security_group"
  description = "SB security group"
  vpc_id = aws_vpc.SB_vpc.id
}

  #인바운드 규칙
resource "aws_security_group_rule" "SB_in" {
    type      = "ingress"
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.SB_security_group.id
    }
  
    
    #아웃바운드 규칙S
resource "aws_security_group_rule" "SB_out" {
    type      = "egress"
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.SB_security_group.id
    }


#IAM 역할 및 정책 생성
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonwas.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_read_access" {
    statement {
      actions = ["s3:Get*", "s3:List*"]

      resources = ["arn:aws:s3:::*"]
    }
  
}

resource "aws_iam_role" "sb_ec2_iam" {
    name = "sb_ec2_iam"

    assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role.json}"
  
}ddd
ddd
resource "aws_iam_role_policy" "join_policy"
    depends_on = [aws_iam_role.sb_ec2_iam]
    name = "join_policy"
    role = "${aws_iam_role.sb_ec2_iam.name}"

    policy = "${data.aws_iam_policy_document.s3_read_access.json}"
  
}


resource "aws_iam_instance_profile" "SB_instance_profile" {
    name = "SB_instance_profile"
    role = "${aws_iam_role.sb_ec2_iam.name}"
  
}

resource "aws_key_pair" "soobin" {
    key_name = "soobin-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuo1gfgfcdGUT1TSgx6W2iGv9WEetNiMC4Of2PtDXt70Ot5JZhJMBVkvB+zqh2NMPg9h3l1JyHvr2Mqsg8JT/w0nu+DWHSNblTXEvxYAhAn5du86hAHl1+9+TX9TUEnzEccr/ec4kZHY537K/dVnuc2lCiq26dsKafER/xS1KeY+7u1EnnQ84wqll6AxXv6SuE0QQdcRcuuAcFgxaPmUmjqxkhXoKFadSp1ipQ+829wXlJ1/Jna/owKcOlbCMfuPvEt+v795Fl4RhuK8ByY+GbA1ShYjtOZ7zkXqYe8WWEzS0cCtsn9O4BX0dakJ9XV1iOInJ7KEM79H7T1xp1jhDl"
}

#EC2설정
resource "aws_instance" "SB_instance" {
    ami = "ami-0bc4327f3aabf5b71"
    instance_type = "t2.micro"
    subnet_id= aws_subnet.SB_subnet.id
    key_name = aws_key_pair.soobin.id
    #iam_instance_profile = aws_iam_instance_profile.SB_instance_profile.id
    vpc_security_group_ids = [aws_security_group.SB_security_group.id]


    #instance_state = "stopped" #running으로 다시 시작 가능
    tags = {
        Name = "SB_instance"
    }

}

#S3설정
resource "aws_s3_bucket" "sbbucket9912" {
    bucket = "sbbucket9912"
    #acl = "public-read-write"
      # `private`, `public-read`, `public-read-write`, `aws-exec-read`, `authenticated-read`, `log-delivery-write` 중 하나 선택. 
  # 기본값은 `private`.
  # `grant`와 대비되는 속성
}