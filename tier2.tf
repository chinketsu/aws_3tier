# Define Security Group for PrivateApp1 and PrivateApp2
resource "aws_security_group" "app_sg" {
  name        = "Private Apps SG"
  vpc_id      = aws_vpc.prodvpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.alb_sg.id, aws_security_group.bastion_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##########

#define ssh key
resource "aws_key_pair" "jump" {
  key_name   = "jump_key"
  public_key = file("./jump.pub")
}


# Defin an autoscaling template
resource "aws_launch_template" "temp_app" {
  image_id = "ami-02d7fd1c2af6eead0"
  monitoring {
    enabled = true
  }
  instance_type   = "t2.micro"
  metadata_options {
   http_endpoint = "enabled"
   http_tokens = "optional"
     }
    key_name   = aws_key_pair.jump.id
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    user_data= filebase64("./userdata.sh")
    ########
    #disable_api_stop = true 
    #disable_api_termination = true 
    ########
    tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "APP"
        }
    }
}

resource "aws_autoscaling_group" "asg" {
  name                  = "App autoscaling group"  
  desired_capacity      = 2
  max_size              = 4
  min_size              = 2
  health_check_type     = "EC2"
  termination_policies  = ["OldestInstance"]
  target_group_arns = [aws_lb_target_group.alb_tg.arn]
  vpc_zone_identifier   = [aws_subnet.private_app1.id, aws_subnet.private_app2.id]
  launch_template {
    id      = aws_launch_template.temp_app.id
    version = "$Latest"
  }
}


##########

#Create Private Route Tables
resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.prodvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
    }
}

resource "aws_route_table_association" "app1_route_table_association" {
  subnet_id      = aws_subnet.private_app1.id
  route_table_id = aws_route_table.app_route_table.id
}

resource "aws_route_table_association" "app2_route_table_association" {
  subnet_id      = aws_subnet.private_app2.id
  route_table_id = aws_route_table.app_route_table.id
}

