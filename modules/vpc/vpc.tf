# Create main VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-vpc"
    Environment = "lesson-8-9"
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
    Environment = "lesson-8-9"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
    Environment = "lesson-8-9"
  }
}

# Create Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
    Environment = "lesson-8-9"
  }
}

# Create Elastic IP for NAT instance
#resource "aws_eip" "nat_eip" {
#  tags = {
#    Name = "${var.vpc_name}-nat-eip"
#  }
#}

# Create NAT instance
#resource "aws_nat_gateway" "nat" {
#  allocation_id = aws_eip.nat_eip.id
#  subnet_id = aws_subnet.public[0].id
#  tags = {
#    Name = "${var.vpc_name}-nat-gw"
#  }
#
#  depends_on = [aws_internet_gateway.igw]
#}