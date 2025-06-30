#######################################
# Public subnets for ALB / NAT Gateway / Bastion
#######################################
resource "aws_subnet" "public" {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = cidrsubnet(aws_vpc.k8s.cidr_block, 4, count.index + (local.subnet_count * 2))
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
    AZ   = data.aws_availability_zones.available.names[count.index]
    Role = "public"
  }
}

#######################################
# Private subnets for controllers
#######################################
resource "aws_subnet" "controller_priv" {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = cidrsubnet(aws_vpc.k8s.cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "controller-priv-subnet-${count.index + 1}"
    AZ   = data.aws_availability_zones.available.names[count.index]
    Role = "k8-controller-priv"
  }
}

#######################################
# Private subnets for workers
#######################################
resource "aws_subnet" "worker_priv" {
  count             = local.subnet_count
  vpc_id            = aws_vpc.k8s.id
  cidr_block        = cidrsubnet(aws_vpc.k8s.cidr_block, 4, count.index + local.subnet_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "worker-priv-subnet-${count.index + 1}"
    AZ   = data.aws_availability_zones.available.names[count.index]
    Role = "k8-worker-priv"
  }
}
#######################################