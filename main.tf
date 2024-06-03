#################################################
### --- VPC ---
#################################################

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}


#################################################
# --- Subnets ---
#################################################

resource "aws_subnet" "public" {
  for_each = {
    for key, value in var.subnets :
    key => value if value.is_private == false
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "private" {
  for_each = {
    for key, value in var.subnets :
    key => value if value.is_private == true
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = each.key
  }
}

###################################################
### --- Internat GateWay  ---
###################################################

resource "aws_internet_gateway" "main" {
  count = var.enable_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-internet-gw"
  }
}

resource "aws_route_table" "this" {
  for_each = {
    for key, value in var.subnets :
    key => value if length(value.routes) != 0
  }

  vpc_id = aws_vpc.main.id


  tags = {
    Name = "${var.name_prefix}-public-subnet-rt"
  }
}

###############################################
# Routes
###############################################

resource "aws_route" "gateway_id" {
  for_each = {
    for route in local.routes : route.name => route if route.gateway_id != null
  }

  route_table_id              = aws_route_table.this[each.value.subnet].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  gateway_id = aws_internet_gateway.main[0].id
}

resource "aws_route" "carrier_gateway_id" {
  for_each = {
    for route in local.routes : route.name => route if route.carrier_gateway_id != null

  }

  route_table_id              = aws_route_table.this[each.value.subnet].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  carrier_gateway_id = each.value.carrier_gateway_id
}

resource "aws_route" "core_network_arn" {
  for_each = {
    for route in local.routes : route.name => route if route.core_network_arn != null

  }

  route_table_id              = aws_route_table.this[each.value.subnet].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  core_network_arn = each.value.core_network_arn
}

resource "aws_route" "egress_only_gateway_id" {
  for_each = {
    for route in local.routes : route.name => route if route.egress_only_gateway_id != null

  }

  route_table_id              = aws_route_table.this[each.value.subnet].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  egress_only_gateway_id = each.value.egress_only_gateway_id
}

# resource "aws_route" "nat_gateway_ref" {
#   for_each = {
#     for key, subnet in var.subnets:
#       key => subnet
#       if subnet.is_private == true && subnet.enable_nat == true
#   }

#   route_table_id              = aws_route_table.this[each.key].id
#   destination_cidr_block      = each.value.routes[0].destination_cidr_block        # Will work only when we have one route 
#   destination_ipv6_cidr_block = each.value.routes[0].destination_ipv6_cidr_block   # Will work only when we have one route 

#   nat_gateway_ref = aws_nat_gateway.this[each.key].id
# }

resource "aws_route" "nat_gateway_ref" {
  for_each = {
    for route in local.routes : route.name => route if route.nat_gateway_ref != null
  }

  route_table_id              = aws_route_table.this[each.value.subnet].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  nat_gateway_id = aws_nat_gateway.this[each.value.nat_gateway_ref].id
}


resource "aws_route" "local_gateway_id" {
  for_each = {
    for route in local.routes : route.name => route if route.local_gateway_id != null
  }

  route_table_id              = aws_route_table.this[each.value.subnet].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  local_gateway_id = each.value.local_gateway_id
}

resource "aws_route" "network_interface_id" {
  for_each = {
    for route in local.routes : route.name => route if route.network_interface_id != null

  }

  route_table_id              = aws_route_table.this[each.value.subnet].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  network_interface_id = each.value.network_interface_id
}

resource "aws_route" "transit_gateway_id" {
  for_each = {
    for route in local.routes : route.name => route if route.transit_gateway_id != null

  }

  route_table_id              = aws_route_table.this[each.value.subnet].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  transit_gateway_id = each.value.transit_gateway_id
}

resource "aws_route" "vpc_endpoint_id" {
  for_each = {
    for route in local.routes : route.name => route if route.vpc_endpoint_id != null
  }

  route_table_id              = aws_route_table.this[each.value.subnet].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  vpc_endpoint_id = each.value.vpc_endpoint_id
}

resource "aws_route" "vpc_peering_connection_id" {
  for_each = {
    for route in local.routes : route.name => route if route.vpc_peering_connection_id != null

  }

  route_table_id              = aws_route_table.this[each.value.subnet].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  vpc_peering_connection_id = each.value.vpc_peering_connection_id
}

##############################################
# Associations
##############################################

resource "aws_route_table_association" "private" {
  for_each = {
    for key, subnet in var.subnets:
      key => subnet
      if subnet.is_private == true && length(subnet.routes) != 0
  }

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}

resource "aws_route_table_association" "public" {
  for_each = {
    for key, subnet in var.subnets:
      key => subnet
      if subnet.is_private == false && length(subnet.routes) != 0
  }


  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}

##################################################
### NAT GateWay  
##################################################

resource "aws_eip" "this" {
  for_each = {
    for key, subnet in var.subnets:
      key => subnet
      if subnet.is_private == true && subnet.enable_nat == true
  }

  tags = {
    Name = "${var.name_prefix}-nat_gw_ip"
  }
}

resource "aws_nat_gateway" "this" {
  for_each = {
    for key, subnet in var.subnets:
      key => subnet
      if subnet.is_private == true && subnet.enable_nat == true
  }

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = aws_subnet.public["first"].id                # Should be a public subnet

  tags = {
    Name = "${var.name_prefix}-nat_gw"
  }
}










