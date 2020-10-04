resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.name_prefix}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.name_prefix}-private-subnet"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_2_subnet_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.name_prefix}-private-subnet-2"
  }
}

resource "aws_eip" "nat_gw_pip" {
  tags = {
    Name = "${var.name_prefix}-nat_gw_pip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gw_pip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.name_prefix}-nat_gw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-main-rt"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-internet-gw"
  }
}

resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-public-subnet-rt"
  }
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_subnet.id
}

resource "aws_security_group" "allow_public_instance_tls" {
  name        = "allow_public_instance_tls"
  description = "Allow TLS inbound traffic for Public Instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MSSQL from Internet"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Oracle-RDS from Internet"
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS from Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "NFS from Internet"
    from_port   = 2049
    to_port     = 2049
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
    Name = "${var.name_prefix}-public-instance-sg"
  }
}

resource "aws_security_group" "allow_private_instance_tls" {
  name        = "allow_private_instance_tls"
  description = "Allow TLS inbound traffic for Private Instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Private Subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  ingress {
    description = "Oracle-RDS from Private Subnet"
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  ingress {
    description = "MYSQL/Aurora from Private Subnet"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  ingress {
    description = "SSH from Private Subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  ingress {
    description = "HTTPS from Private Subnet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  ingress {
    description = "All ICMP - IPv4 from Private Subnet"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-private-instance-sg"
  }
}
