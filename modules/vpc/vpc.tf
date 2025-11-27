# Create main VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block   # CIDR block for our VPC (e.g., 10.0.0.0/16)
  enable_dns_support = true                 # Enable DNS support in VPC
  enable_dns_hostnames = true                 # Enable DNS hostnames for resources in VPC

  tags = {
    Name = "${var.vpc_name}-vpc"              # Add tag that includes VPC name
    Environment = "lesson-10"
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)   # Create multiple subnets, quantity determined by length of public_subnets list
  vpc_id = aws_vpc.main.id              # Attach each subnet to the VPC created earlier
  cidr_block = var.public_subnets[count.index] # CIDR block for specific subnet from public_subnets list
  availability_zone = var.availability_zones[count.index] # Define availability zones for each subnet
  map_public_ip_on_launch = true                         # Automatically assign public IP addresses to instances in subnet

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"  # Tag with subnet numbering
    # count.index is the index of the "count" loop, which starts at 0.
    # ${count.index + 1} adds +1 to the index to get human-readable numbering (1, 2, 3 instead of 0, 1, 2).
    Environment = "lesson-10"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)   # Create multiple private subnets, quantity matches length of private_subnets list
  vpc_id = aws_vpc.main.id               # Attach each private subnet to VPC
  cidr_block = var.private_subnets[count.index] # CIDR block for specific subnet from private_subnets list
  availability_zone = var.availability_zones[count.index] # Define availability zones for subnets

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"  # Tag for subnet with numbering
    # ${count.index + 1} is used so subnet numbering starts at 1.
    Environment = "lesson-10"
  }
}

# Create Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id   # Attach Internet Gateway to VPC for internet access

  tags = {
    Name = "${var.vpc_name}-igw"   # Tag for Internet Gateway identification
    Environment = "lesson-10"
  }
}

## Create Elastic IP for NAT instance
#resource "aws_eip" "nat_eip" {
#  tags = {
#    Name = "${var.vpc_name}-nat-eip"
#  }
#}

## Create NAT instance
#resource "aws_nat_gateway" "nat" {
#  allocation_id = aws_eip.nat_eip.id
#  subnet_id = aws_subnet.public[0].id  # NAT Gateway must be in public subnet
#  tags = {
#    Name = "${var.vpc_name}-nat-gw"
#  }
#
#  depends_on = [aws_internet_gateway.igw]
#}
