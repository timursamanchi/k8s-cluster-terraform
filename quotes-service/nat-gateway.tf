#######################################
# NAT Gateway + Elastic IP
#######################################
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "k8s-nat-eip"
  }
}

resource "aws_nat_gateway" "k8s_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "k8s-nat-gateway"
  }
}
#######################################