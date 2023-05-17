provider "aws" {

    region = "ap-south-1"
    access_key = ""
    secret_key = ""
}

# Creating the VPC
resource "aws_vpc" "Mobilics" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Private"
  }
}

# Creating the Internet Gateway
resource "aws_internet_gateway" "Mobilics" {
  vpc_id = aws_vpc.Mobilics.id

  tags = {
    Name = "Mobilics_IGW"
  }
}

# Creating the first subnet
resource "aws_subnet" "Mobilics_Subnet_1" {
  vpc_id     = aws_vpc.Mobilics.id
  cidr_block = "10.0.0.0/25"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Mobilics_Subnet_1"
  }
}

# Creating the second subnet
resource "aws_subnet" "Mobilics_Subnet_2" {
  vpc_id     = aws_vpc.Mobilics.id
  cidr_block = "10.0.0.128/25"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Mobilics_Subnet_2"
  }
}

# Creating the Route Table
resource "aws_route_table" "Mobilics_Route_Table" {
  vpc_id = aws_vpc.Mobilics.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Mobilics.id
  }

  tags = {
    Name = "Mobilics_Route_Table"
  }
}

# Associating the first subnet with the Route Table
resource "aws_route_table_association" "Mobilics_Subnet_1_Association" {
  subnet_id      = aws_subnet.Mobilics_Subnet_1.id
  route_table_id = aws_route_table.Mobilics_Route_Table.id
}

# Associating the second subnet with the Route Table
resource "aws_route_table_association" "Mobilics_Subnet_2_Association" {
  subnet_id      = aws_subnet.Mobilics_Subnet_2.id
  route_table_id = aws_route_table.Mobilics_Route_Table.id
}

# Creating the Security Group
resource "aws_security_group" "Mobilics_SG" {
  name   = "Mobilics_SG"
  vpc_id = aws_vpc.Mobilics.id

  ingress {
    description = "HTTP"
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
    Name = "Mobilics_SG"
  }
}

# Creating the first EC2 instance
resource "aws_instance" "Mobilics_Instance_1" {
  ami           = "ami-025b4b7b37b743227"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Mobilics_Subnet_1.id
  vpc_security_group_ids = [aws_security_group.Mobilics_SG.id]

  tags = {
    Name = "Mobilics_Instance_1"
  }
}

# Creating the second EC2 instance
resource "aws_instance" "Mobilics_Instance_2" {
  ami           = "ami-025b4b7b37b743227"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Mobilics_Subnet_2.id
  vpc_security_group_ids = [aws_security_group.Mobilics_SG.id]

  tags = {
    Name = "Mobilics_Instance_2"
  }
}

# Creating a Load Balancer
resource "aws_lb" "Mobilics-ALB" {
  name               = "Mobilics-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Mobilics_SG.id]
  subnets            = [aws_subnet.Mobilics_Subnet_1.id, aws_subnet.Mobilics_Subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "Mobilics-ALB"
  }
}

# Defining a default target group for the Load Balancer
resource "aws_lb_target_group" "Mobilics-ALB-TG" {
  name     = "Mobilics-ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Mobilics.id

  health_check {
    enabled = true
    path    = "/"
    timeout = 3
  }
}

# Associating the target group with the Load Balancer
resource "aws_lb_listener" "Mobilics-ALB-Listener" {
  load_balancer_arn = aws_lb.Mobilics-ALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Mobilics-ALB-TG.arn
  }
}

# Registering EC2 instances with the target group
resource "aws_lb_target_group_attachment" "Mobilics-ALB-TG-Attachment-1" {
  target_group_arn = aws_lb_target_group.Mobilics-ALB-TG.arn
  target_id        = aws_instance.Mobilics_Instance_1.id
}

resource "aws_lb_target_group_attachment" "Mobilics-ALB-TG-Attachment-2" {
  target_group_arn = aws_lb_target_group.Mobilics-ALB-TG.arn
  target_id        = aws_instance.Mobilics_Instance_2.id
}