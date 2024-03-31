#Create VPC
resource "aws_vpc" "nonprodvpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support = false
  enable_dns_hostnames = false
  tags = {
    Name = "NonProd VPC"
  }
}


#Create Subnet

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.nonprodvpc.id
  cidr_block              = "10.1.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
      Name = "NonProd Subnet1"
  }
}

#Create Transit Gateway
#resource "aws_ec2_transit_gateway" "tgw" {
    #default_route_table_association = "disable"
    #default_route_table_propagation = "disable"
    #tags = {
    #Name = "Transit GW"
    #}
#}


#resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_nonprod" {
  #subnet_ids         = [aws_subnet.private.id]
  #transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  #vpc_id             = aws_vpc.nonprodvpc.id
#}

# routing


resource "aws_route_table" "nonprod_route" {
  vpc_id                  = aws_vpc.nonprodvpc.id
  route {
    cidr_block         = "10.2.0.0/16"
    #transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    vpc_peering_connection_id = aws_vpc_peering_connection.scan.id
  }
}
resource "aws_route_table_association" "nonprod_rt_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.nonprod_route.id
}

##Security Group 5 OS

resource "aws_security_group" "nonprod_sg" {
  name        = "nonprod_sg"
  vpc_id      = aws_vpc.nonprodvpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.2.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.2.0.0/16"]
  }
}

resource "aws_network_interface" "ip1" {
  subnet_id       = aws_subnet.private.id
  private_ips     = ["10.1.0.11"]
  security_groups = [aws_security_group.nonprod_sg.id]
}

resource "aws_network_interface" "ip2" {
  subnet_id       = aws_subnet.private.id
  private_ips     = ["10.1.0.12"]
  security_groups = [aws_security_group.nonprod_sg.id]
}

resource "aws_network_interface" "ip3" {
  subnet_id       = aws_subnet.private.id
  private_ips     = ["10.1.0.13"]
  security_groups = [aws_security_group.nonprod_sg.id]
}

resource "aws_network_interface" "ip4" {
  subnet_id       = aws_subnet.private.id
  private_ips     = ["10.1.0.14"]
  security_groups = [aws_security_group.nonprod_sg.id]
}

resource "aws_network_interface" "ip5" {
  subnet_id       = aws_subnet.private.id
  private_ips     = ["10.1.0.15"]
  security_groups = [aws_security_group.nonprod_sg.id]
}

resource "aws_instance" "nonprod1" {
  ami                         = "ami-0fe630eb857a6ec83"
  instance_type               = "t2.micro"
  #subnet_id                   = aws_subnet.private.id
  availability_zone           = "us-east-1a"
  network_interface {
     network_interface_id = "${aws_network_interface.ip1.id}"
     device_index = 0
  }
  #vpc_security_group_ids = [aws_security_group.nonprod_sg.id]
  key_name   = aws_key_pair.simu.id
  tags = {
    Name = "nonprod1"
  }
}

resource "aws_instance" "nonprod2" {
  ami                         = "ami-0a55ba1c20b74fc30"
  instance_type               = "t4g.nano"
  #subnet_id                   = aws_subnet.private.id
  availability_zone           = "us-east-1a"
  #vpc_security_group_ids = [aws_security_group.nonprod_sg.id]
  network_interface {
     network_interface_id = "${aws_network_interface.ip2.id}"
     device_index = 0
  }
  key_name   = aws_key_pair.simu.id
  tags = {
    Name = "nonprod2"
  }
}
resource "aws_instance" "nonprod3" {
  ami                         = "ami-0a55ba1c20b74fc30"
  instance_type               = "t4g.nano"
  #subnet_id                   = aws_subnet.private.id
  availability_zone           = "us-east-1a"
  network_interface {
     network_interface_id = "${aws_network_interface.ip3.id}"
     device_index = 0
  }
  #vpc_security_group_ids = [aws_security_group.nonprod_sg.id]
  key_name   = aws_key_pair.simu.id
  tags = {
    Name = "nonprod3"
  }
}
resource "aws_instance" "nonprod4" {
  ami                         = "ami-0a55ba1c20b74fc30"
  instance_type               = "t4g.nano"
  #subnet_id                   = aws_subnet.private.id
  network_interface {
     network_interface_id = "${aws_network_interface.ip4.id}"
     device_index = 0
  }
  availability_zone           = "us-east-1a"
  #vpc_security_group_ids = [aws_security_group.nonprod_sg.id]
  key_name   = aws_key_pair.simu.id
  tags = {
    Name = "nonprod4"
  }
}
resource "aws_instance" "nonprod5" {
  ami                         = "ami-0a55ba1c20b74fc30"
  instance_type               = "t4g.nano"
  #subnet_id                   = aws_subnet.private.id
  availability_zone           = "us-east-1a"
  #vpc_security_group_ids = [aws_security_group.nonprod_sg.id]
  network_interface {
     network_interface_id = "${aws_network_interface.ip5.id}"
     device_index = 0
  }
  key_name   = aws_key_pair.simu.id
  tags = {
    Name = "nonprod5"
  }
}

