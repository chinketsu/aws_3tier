resource "aws_security_group" "db_sg" {
    name        = "database_sg"
    description = "database_sg"
    vpc_id      = aws_vpc.prodvpc.id

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        cidr_blocks      = ["10.0.0.0/16"]
        security_groups = [aws_security_group.app_sg.id]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}

#make a key for encrypt data
resource "aws_kms_key" "kms_key" {
  description = "My KMS Key for RDS Encryption"
  deletion_window_in_days = 30
  tags = {
    Name = "KMS Key"
  }
}

#create data base
resource "aws_db_subnet_group" "database_subnet_group" {
  subnet_ids = [aws_subnet.private_db1.id, aws_subnet.private_db2.id]
}



resource "aws_db_instance" "prim" {
    identifier                   = "prim"
    db_name                     = "prim"
    allocated_storage      = 8
    storage_type                = "gp2"
    engine = "mysql"
    instance_class = "db.t3.micro"
    username = "root"
    password = "cohort10"
    db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.id
    vpc_security_group_ids = [aws_security_group.db_sg.id]
    multi_az = true
    skip_final_snapshot = true
    backup_retention_period = 2
    backup_window = "03:00-04:00"
    maintenance_window = "mon:04:00-mon:04:30"
    storage_encrypted = true
    kms_key_id = aws_kms_key.kms_key.arn
}

#   data "local_file" "sql_script" {
#     filename = "./inventory.sql"
#   }

#   resource "null_resource" "db_setup" {
#     provisioner "local-exec" {
#       command="mysql --host=${aws_db_instance.prim.address} --user=cohort10 --password=cohort10 --database=prim < ${data.local_file.sql_script.content}"
#       }
#   }

#   #Associate Private Route Tables
#   resource "aws_route_table_association" "db1_route_table_association" {
#     subnet_id      = aws_subnet.private_db1.id
#     route_table_id = aws_route_table.app_route_table.id
#   }
#   resource "aws_route_table_association" "db2_route_table_association" {
#     subnet_id      = aws_subnet.private_db2.id
#     route_table_id = aws_route_table.app_route_table.id
#   }
