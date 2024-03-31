# Public routing
resource "aws_route_table" "public_subnet_route_table" {
    vpc_id = aws_vpc.prodvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod_igw.id
    }
}
resource "aws_route_table_association" "public1_route_table_association" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}
resource "aws_route_table_association" "public2_route_table_association" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}


# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Creat NAT Gateway
resource "aws_nat_gateway" "nat" {
  depends_on = [aws_internet_gateway.prod_igw]
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "NAT Gateway"
  }
}

#   resource "aws_route_table" "nat_route_table" {
#     vpc_id = aws_vpc.prodvpc.id
#     route {
#       cidr_block = "0.0.0.0/0"
#       nat_gateway_id = aws_nat_gateway.nat.id
#     }
#   }


#################

#define ssh key
resource "aws_key_pair" "bastion" {
  key_name   = "bastion_key"
  public_key = file("./bastion.pub")
}



# Create Bastion
resource "aws_instance" "bastion" {
    ami                         = "ami-0e731c8a588258d0d"
    instance_type               = "t2.micro"
    tags = {
        Name = "Bastion Host"
      }
    key_name   = aws_key_pair.bastion.id
    subnet_id                   =  aws_subnet.public2.id
    vpc_security_group_ids      = [aws_security_group.bastion_sg.id]  
    instance_initiated_shutdown_behavior = "terminate"
    monitoring                           = true
    tenancy                              = "default"
    ebs_optimized                        = false
    associate_public_ip_address = true
    user_data= filebase64("./bastion_userdata.sh")
}


# Create Bastion SG
resource "aws_security_group" "bastion_sg" {
  description = "EC2 Bastion Host Security Group"
  name = "Bastion SG"
  vpc_id = aws_vpc.prodvpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open to Public Internet"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open to Public Internet"
  }
}



output "bastion_ip_address" {
    value = aws_instance.bastion.public_ip
}

################

# Creating Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "ALB Security Group"
  vpc_id = aws_vpc.prodvpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
      }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  }


# Create Internet-Facing Application Load Balancer (ALB)
resource "aws_lb" "alb" {
  internal = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [aws_subnet.public1.id, aws_subnet.public2.id]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  enable_http2=false
}

# create target group for alb
resource "aws_lb_target_group" "alb_tg" {
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.prodvpc.id
}

#   resource "aws_lb_target_group_attachment" "attachment" {
#     target_group_arn = aws_lb_target_group.alb_tg.arn
#     target_id= aws_autoscaling_group.asg.id
#     port             = 80
#     #depends_on = [aws_autoscaling_group.asg]
#   }


resource "aws_lb_listener" "alb_listener_2" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "80"
    protocol          = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.alb_tg.arn
    }
}

output "alb_address" {
    value = aws_lb.alb.dns_name
}
