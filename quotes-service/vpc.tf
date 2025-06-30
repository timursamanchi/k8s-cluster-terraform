#######################################
# VPC setting for k8s cluster
#######################################
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "k8s" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "k8s-vpc"
  }
}

resource "aws_internet_gateway" "k8s" {
  vpc_id = aws_vpc.k8s.id
  tags = {
    Name = "k8s-internet-gateway"
  }
}