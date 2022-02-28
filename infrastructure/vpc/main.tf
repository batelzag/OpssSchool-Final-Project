# Create VPC
resource "aws_vpc" "project-vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_hostnames  = true
  enable_dns_support    = true
  
  tags = {
    Name = "project-vpc"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count                   = var.number_of_private_subnets
  vpc_id                  = aws_vpc.project-vpc.id
  cidr_block              = cidrsubnet("${var.vpc_cidr}", 8, 10 + count.index)
  availability_zone       = element(data.aws_availability_zones.available-AZ.names,count.index)
  map_public_ip_on_launch = false
  
  tags = {
    Name = "private-sub${count.index + 1}"
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count                   = var.number_of_public_subnets
  vpc_id                  = aws_vpc.project-vpc.id
  cidr_block              = cidrsubnet("${var.vpc_cidr}", 8, 100 + count.index)
  availability_zone       = element(data.aws_availability_zones.available-AZ.names,count.index)
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-sub${count.index + 1}"
  }
}

# Create Internet gateway
resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.project-vpc.id
  
  tags = {
    Name = "internet-gw"
  }
}

# Create EIP for NAT gatways
resource "aws_eip" "nat-eip" {
  count      = var.number_of_public_subnets
  vpc        = true
  depends_on = [aws_internet_gateway.internet-gw]
  
  tags = {
    Name = "nat-eip${count.index +1}"
  }
}

# Create NAT gatway for each AZ
resource "aws_nat_gateway" "nat-gw" {
  count             = var.number_of_private_subnets
  connectivity_type = "public"
  allocation_id     = "${element(aws_eip.nat-eip.*.id,count.index)}"
  subnet_id         = "${element(aws_subnet.public.*.id,count.index)}"
  depends_on        = [aws_internet_gateway.internet-gw]
  
  tags = {
    Name = "nat-gw${count.index +1}"
  }
}

# Create public Route-Table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.project-vpc.id
  
  tags = {
    Name = "public-rt"
  }
}

# Create private Route-Table for each AZ
resource "aws_route_table" "private-rt" {
  count   = var.number_of_private_subnets
  vpc_id  = aws_vpc.project-vpc.id
  
  tags = {
    Name = "private-rt-${element(data.aws_availability_zones.available-AZ.names,count.index)}"
  }
}

resource "aws_route" "public-igw" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gw.id
}

resource "aws_route" "private-nat" {
  count                  = var.number_of_private_subnets
  route_table_id         = "${element(aws_route_table.private-rt.*.id,count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat-gw.*.id,count.index)}"
}

resource "aws_route_table_association" "rta-public" {
  count          = var.number_of_public_subnets
  subnet_id      = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "rta-private" {
  count          = var.number_of_public_subnets
  subnet_id      = "${element(aws_subnet.private.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.private-rt.*.id,count.index)}"
}