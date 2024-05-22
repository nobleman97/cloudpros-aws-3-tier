resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index].cidr_block
  availability_zone = var.public_subnets[count.index].availability_zone

  tags = {
    Name = "${var.name_prefix}-${var.public_subnets[count.index]}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index].cidr_block
  availability_zone = var.public_subnets[count.index].availability_zone

  tags = {
    Name = "${var.name_prefix}-${var.private_subnets[count.index]}-private-subnet"
  }
}

