#######################################
# Public Subnets Route Table and route table association - bastion, NAT gateway, and network/apps load balancers
#######################################
resource "aws_route_table" "public" {
  # Route table for public subnets: routes 0.0.0.0/0 via internet gateway
  vpc_id = aws_vpc.k8s.id
  tags = {
    Name = "k8s-public-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s.id
  }
}

resource "aws_route_table_association" "public" {
  # Associates public subnets with the public route table
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#######################################
# Private Subnets Route Table and route table associations for controllers + workers
#######################################
resource "aws_route_table" "private" {
  # Route table for private subnets: routes 0.0.0.0/0 via NAT gateway for outbound internet
  vpc_id = aws_vpc.k8s.id
  tags = {
    Name = "k8s-private-route-table"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k8s_nat.id
  }
}

resource "aws_route_table_association" "controller_priv" {
  # Associates private controller subnets with the private route table
  count          = length(aws_subnet.controller_priv)
  subnet_id      = aws_subnet.controller_priv[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "worker_priv" {
  # Associates private worker subnets with the private route table
  count          = length(aws_subnet.worker_priv)
  subnet_id      = aws_subnet.worker_priv[count.index].id
  route_table_id = aws_route_table.private.id
}
#######################################