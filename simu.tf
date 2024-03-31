#Create VPC
resource "aws_vpc" "simuvpc" {
  cidr_block = "10.2.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Simulated VPC"
  }
}

resource "aws_vpc_peering_connection" "scan" {
  vpc_id        = aws_vpc.simuvpc.id
  peer_vpc_id   = aws_vpc.nonprodvpc.id
    auto_accept = true
}

#Create Internet Gateway
resource "aws_internet_gateway" "simu_igw" {
  vpc_id = aws_vpc.simuvpc.id
  tags = {
    Name = "Simu IGW"
  }
}

    ##Create Public Subnet
    #resource "aws_subnet" "public" {
      #vpc_id                  = aws_vpc.simuvpc.id
      #cidr_block              = "10.2.1.0/24"
      #availability_zone       = "us-east-1a"
      #map_public_ip_on_launch = true
    #}

#Create  Subnet
resource "aws_subnet" "office" {
  vpc_id                  = aws_vpc.simuvpc.id
  cidr_block              = "10.2.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}


    ## Create Elastic IP for NAT Gateway
    #resource "aws_eip" "nat_eip_office" {
      #vpc = true
    #}
    ## Creat NAT Gateway
    #resource "aws_nat_gateway" "nat_sim" {
      #depends_on = [aws_internet_gateway.simu_igw]
      #allocation_id = aws_eip.nat_eip_office.id
      #subnet_id     = aws_subnet.public.id
    #}






#resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_office" {
  #subnet_ids         = [aws_subnet.office.id]
  #transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  #vpc_id             = aws_vpc.simuvpc.id
#}

# routing
resource "aws_route_table" "office_route" {
  vpc_id        = aws_vpc.simuvpc.id
  route {
    cidr_block         = "10.1.0.0/16"
    #transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    vpc_peering_connection_id = aws_vpc_peering_connection.scan.id
  }
   route {
        cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.simu_igw.id
    }
}

resource "aws_route_table_association" "simu_rt_association" {
  subnet_id      = aws_subnet.office.id
  route_table_id = aws_route_table.office_route.id
}

#Security group
resource "aws_security_group" "simu_sg" {
  name        = "simu_sg"
  vpc_id      = aws_vpc.simuvpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.0.0/16"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open to Public Internet"
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open to Public Internet"
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open to Public Internet"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open to Public Internet"
  }
}

#define ssh key
resource "aws_key_pair" "simu" {
  key_name   = "simu_key"
  public_key = file("./jump.pub")
}



# Create Simu PC

resource "aws_instance" "simu" {
  ami                         = "ami-02d7fd1c2af6eead0"
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.office.id
  availability_zone           = "us-east-1a"
  root_block_device {
    volume_size = "15"
    encrypted = false
  }
  key_name   = aws_key_pair.simu.id
  vpc_security_group_ids = [aws_security_group.simu_sg.id]
    user_data= filebase64("./onprem_userdata.sh")
    ########
    #disable_api_stop = true 
    #disable_api_termination = true 
    ########
  tags = {
    Name = "simu"
  }
}




output "onprem_ip_address" {
    value = aws_instance.simu.public_ip
}

