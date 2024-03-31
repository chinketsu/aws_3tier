#Create VPC
resource "aws_vpc" "prodvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Prod VPC"
  }
}


#Create Public Subnet

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.prodvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.prodvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet2"
  }
}

#Create Private Subnet

resource "aws_subnet" "private_app1" {
  vpc_id                  = aws_vpc.prodvpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet APP1"
  }
}

resource "aws_subnet" "private_app2" {
  vpc_id                  = aws_vpc.prodvpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet APP2"
  }
}

resource "aws_subnet" "private_db1" {
  vpc_id                  = aws_vpc.prodvpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet DB1"
  }
}

resource "aws_subnet" "private_db2" {
  vpc_id                  = aws_vpc.prodvpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet DB2"
  }
}

#Create Internet Gateway

resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prodvpc.id
  tags = {
    Name = "Prod IGW"
  }
}
