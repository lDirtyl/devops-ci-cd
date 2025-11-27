 # Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id  # Attach table to our VPC

  tags = {
    Name = "${var.vpc_name}-public-rt"  # Tag for route table
  }
}

# Add route for internet access through Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id  # Route table ID
  destination_cidr_block = "0.0.0.0/0"               # All IP addresses
  gateway_id = aws_internet_gateway.igw.id  # Specify Internet Gateway as exit
}

# Attach route table to public subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)  # Attach each subnet
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

 ## Create route table for private subnets
 #resource "aws_route_table" "private" {
 #  vpc_id = aws_vpc.main.id
 #
 #  route {
 #    cidr_block = "0.0.0.0/0"
 #    nat_gateway_id = aws_nat_gateway.nat.id
 #  }
 #
 #  tags = {
 #    Name = "${var.vpc_name}-private-rt"
 #  }
 #}
 #
 ## Attach route table to private subnets
 #resource "aws_route_table_association" "private" {
 #  count = length(var.private_subnets)
 #  subnet_id = aws_subnet.private[count.index].id
 #  route_table_id = aws_route_table.private.id
 #}
