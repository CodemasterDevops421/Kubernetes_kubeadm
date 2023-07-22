# Define the AWS provider and region
provider "aws" {
  region = var.location
}

# Create VPC
resource "aws_vpc" "demo-vpc" {
  cidr_block = var.vpc-cidr
}

# Create Subnet
resource "aws_subnet" "demo-subnet" {
  vpc_id            = aws_vpc.demo-vpc.id
  cidr_block        = var.subnet1-cidr
  availability_zone = var.subnet-az

  tags = {
    Name = "demo_subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-igw"
  }
}

# Create Route Table and associate the Subnet with it
resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }

  tags = {
    Name = "demo-rt"
  }
}

resource "aws_route_table_association" "demo-rt_association" {
  subnet_id      = aws_subnet.demo-subnet.id
  route_table_id = aws_route_table.demo-rt.id
}

# Create Security Group
resource "aws_security_group" "demo-vpc-sg" {
  name   = "demo-vpc-sg"
  vpc_id = aws_vpc.demo-vpc.id

  # Ingress rules for SSH, HTTP, HTTPS, and custom ports for control plane and worker nodes
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rules for the Kubernetes control plane components
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for NodePort Services on worker nodes
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main"
  }
}

# Create Kubernetes Control Plane Instance
resource "aws_instance" "control-plane" {
  ami                         = var.os_name
  key_name                    = var.key
  instance_type               = var.control_plane_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.demo-subnet.id
  vpc_security_group_ids      = [aws_security_group.demo-vpc-sg.id]

  tags = {
    Name = "control-panel"
  }
}

# Create Kubernetes Worker Node Instance
resource "aws_instance" "worker-node" {
  ami                         = var.os_name
  key_name                    = var.key
  instance_type               = var.worker_instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.demo-subnet.id
  vpc_security_group_ids      = [aws_security_group.demo-vpc-sg.id]

  tags = {
    Name = "worker-node"
  }
}
