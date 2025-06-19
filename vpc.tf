provider "aws" {
    region = "ap-south-1"
  
}

resource "aws_vpc" "EKS_VPC" {
    cidr_block = "10.0.0.0/16"
  
}


resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.EKS_VPC.id
  
}
resource "aws_subnet" "EKS_Pub_Sub" {
    #count = 
    vpc_id = aws_vpc.EKS_VPC.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
  
}

resource "aws_subnet" "EKS_Pub_Sub-1" {
    #count = 
    vpc_id = aws_vpc.EKS_VPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
  
}

resource "aws_subnet" "EKS_Pri_Sub" {
    vpc_id = aws_vpc.EKS_VPC.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1c"
  
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.EKS_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }
}


resource "aws_route_table_association" "pub_rta" {
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.EKS_Pub_Sub-1.id
  
}


resource "aws_route_table_association" "pub_rta-1" {
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.EKS_Pub_Sub.id
  
}

resource "aws_eip" "ngw_id" {
    domain = "vpc"
  
}

resource "aws_nat_gateway" "ngw" {
    subnet_id = aws_subnet.EKS_Pri_Sub.id
    allocation_id = aws_eip.ngw_id.id
  
}

resource "aws_route_table" "Pri_rt" {
  vpc_id = aws_vpc.EKS_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id

  }
}

resource "aws_route_table_association" "pri_rta" {
    subnet_id = aws_subnet.EKS_Pri_Sub.id
    route_table_id = aws_route_table.Pri_rt.id
  
}

resource "aws_security_group" "sg_id" {
  vpc_id = aws_vpc.EKS_VPC.id

  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }    


  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_security_group_rule" "allow_alb_to_nodes" {
#   type                     = "ingress"
#   from_port                = 80                           # Or your application's port
#   to_port                  = 80
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.sg_id.id  # EKS NodeGroup SG
#   source_security_group_id = "sg-0bd48d5875f8fcfb1"      # Replace with your ALB SG
# }