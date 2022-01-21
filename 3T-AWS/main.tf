# [AK] Defining region and AWS profile
provider "aws" {
  region  = "ap-southeast-1"
}
# [AK] Network-Defining VPC and CIDR range
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "AK-lab-vpc"
  }
}
# [AK] Network-Defining Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "AK-lab-internet-gateway"
  }
}
# [AK] Network-Defining Public Subnet-1
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.main.id

  availability_zone = "ap-southeast-1a"
  cidr_block        = "192.168.1.0/24"

  tags = {
    Name = "AK-lab-public-subnet-PUblic1"
  }
}
# [AK] Network-Defining Public Subnet-2
resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.main.id

  availability_zone = "ap-southeast-1b"
  cidr_block        = "192.168.4.0/24"

  tags = {
    Name = "AK-lab-public-subnet-PUblic2"
  }
}
# [AK] Network-Defining Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id

  availability_zone = "ap-southeast-1a"
  cidr_block        = "192.168.2.0/24"

  tags = {
    Name = "AK-lab-Private-subnet-Private"
  }
}
# [AK] Network-Defining Database Subnet-1
resource "aws_subnet" "database_subnet_1" {
  vpc_id = aws_vpc.main.id

  availability_zone = "ap-southeast-1a"
  cidr_block        = "192.168.3.0/24"

  tags = {
    Name = "AK-lab-Private-subnet-1-Database"
  }
}
# [AK] Network-Defining Database Subnet-2
resource "aws_subnet" "database_subnet_2" {
  vpc_id = aws_vpc.main.id

  availability_zone = "ap-southeast-1b"
  cidr_block        = "192.168.5.0/24"

  tags = {
    Name = "AK-lab-Private-subnet-2-Database"
  }
}
# [AK] Network-Defining Route Table 
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "AK-public-subnet-route-table"
  }
}
# [Ak] Network- Defining Public subnet route table association 1
resource "aws_route_table_association" "public_subnet_route_table_association1" {

  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}
# [Ak] Network- Defining Public subnet route table association 2
resource "aws_route_table_association" "public_subnet_route_table_association2" {

  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}
# [AK] Web - Defining Application Load Balancer (*** Must have two Subnet)
resource "aws_lb" "web_app_lb" {
  name               = "web-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_http.id]
  subnet_mapping {
    subnet_id     = aws_subnet.public_subnet_1.id
  }
  subnet_mapping {
    subnet_id     = aws_subnet.public_subnet_2.id
  }
}
# [AK] Web - Defining ALB Security Group
resource "aws_security_group" "alb_http" {
  name        = "alb-web-security-group"
  description = "Allowing HTTP requests to the application load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AK-alb-web-security-group"
  }
}
# [AK] Web - Defining Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port     = "80"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

# [AK] Web - Defining Target Group
resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    port     = 80
    protocol = "HTTP"
  }
}
# [AK] Web - Defining EC2 Instance Security Group
resource "aws_security_group" "web_instance_sg" {
  name        = "web-server-security-group"
  description = "Allowing requests to the web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_http.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AK-web-server-security-group"
  }
}
# [AK] Web - Defining Launch Template
resource "aws_launch_template" "web_launch_template" {
  name_prefix   = "web-launch-template"
  image_id      = "ami-0e2e44c03b85f58b3"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_instance_sg.id]
  
  tags = {
    Name = "AK-lab-EC2"
  }
}
# [AK] Web - Defining Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.web_target_group.arn]
  vpc_zone_identifier = [aws_subnet.public_subnet_1.id]

  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }
}
# [AK] App - Defining ALB Security Group
resource "aws_security_group" "alb_app_http" {
  name        = "alb-app-security-group"
  description = "Allowing HTTP requests to the app tier application load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AK-alb-app-security-group"
  }
}

# [AK] App - Defining Application Load Balancer
resource "aws_lb" "appl_app_lb" {
  name               = "app-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_app_http.id]
  subnet_mapping {
    subnet_id     = aws_subnet.public_subnet_1.id
  }
  subnet_mapping {
    subnet_id     = aws_subnet.public_subnet_2.id
  }
}
# [AK] App - Defining Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.appl_app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

# [AK] App - Defining Target Group
resource "aws_lb_target_group" "app_target_group" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    port     = 80
    protocol = "HTTP"
  }
}

# App - [AK] Definning EC2 Instance Security Group
resource "aws_security_group" "app_instance_sg" {
  name        = "app-server-security-group"
  description = "Allowing requests to the app servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_app_http.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AK-app-server-security-group"
  }
}

# [AK] App - Defining Launch Template
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-launch-template"
  image_id      = "ami-0e2e44c03b85f58b3"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_instance_sg.id]
  
  tags = {
    Name = "AK-lab-EC2"
  }
}

# App - Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.app_target_group.arn]
  vpc_zone_identifier = [aws_subnet.private_subnet.id]

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
}

# [AK] DB - Defining Security Group
resource "aws_security_group" "db_security_group" {
  name = "mydb1"

  description = "RDS postgres server"
  vpc_id      = aws_vpc.main.id

  # Only postgres in
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_instance_sg.id]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# [AK] DB - Defining Subnet Group
resource "aws_db_subnet_group" "database_subnet" {
  name       = "database-subnet"
  subnet_ids = [aws_subnet.database_subnet_1.id, aws_subnet.database_subnet_2.id]

  tags = {
    Name = "AK-My DB subnet group"
  }
}

# [AK] DB - Defining RDS Instances
resource "aws_db_instance" "db_postgres" {
  allocated_storage       = 256 # gigabytes
  backup_retention_period = 7   # in days
  db_subnet_group_name    = aws_db_subnet_group.database_subnet.name
  engine                  = "postgres"
  engine_version          = "12.4"
  identifier              = "dbpostgres"
  instance_class          = "db.t3.micro"
  multi_az                = false
  name                    = "dbpostgres"
  username                = "dbadmin"
  password                = "set-your-own-password!"
  port                    = 5432
  publicly_accessible     = false
  storage_encrypted       = true
  storage_type            = "gp2"
  vpc_security_group_ids  = [aws_security_group.db_security_group.id]
  skip_final_snapshot     = true
}
