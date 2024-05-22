resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index].cidr_block
  availability_zone       = var.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = var.public_subnets[count.index].map_public_ip_on_launch

  tags = {
    Name = "${var.name_prefix}-${var.public_subnets[count.index].name}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index].cidr_block
  availability_zone = var.private_subnets[count.index].availability_zone

  tags = {
    Name = "${var.name_prefix}-${var.private_subnets[count.index].name}-private-subnet"
  }
}

### --- Internat GateWay  ---

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-internet-gw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-public-subnet-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}




### --- NAT GateWay  ---

resource "aws_eip" "nat_gw_ip" {
  count = var.enable_private_subnets ? 1 : 0

  tags = {
    Name = "${var.name_prefix}-nat_gw_ip"
  }
}

resource "aws_nat_gateway" "main" {
  count = var.enable_private_subnets ? 1 : 0

  allocation_id = aws_eip.nat_gw_ip[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.name_prefix}-nat_gw"
  }
}


resource "aws_route_table" "private" {
  count  = var.enable_private_subnets ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main[0].id
  }

  tags = {
    Name = "${var.name_prefix}-secondary-rt"
  }
}

resource "aws_route_table_association" "private" {
  count = var.enable_private_subnets ? length(var.private_subnets) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}