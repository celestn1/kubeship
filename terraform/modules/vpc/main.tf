// kubeship/terraform/modules/vpc/main.tf

// Create the main VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

// Create public subnets across availability zones
resource "aws_subnet" "public" {
  for_each = toset(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, index(var.availability_zones, each.value))
  map_public_ip_on_launch = true
  availability_zone       = each.value

  tags = {
    Name    = "${var.project_name}-public-${each.value}"
    Project = var.project_name
  }
}

// Create private subnets across availability zones
resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, index(var.availability_zones, each.value) + 100)
  availability_zone = each.value

  tags = {
    Name    = "${var.project_name}-private-${each.value}"
    Project = var.project_name
  }
}

// Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

// Public route table and route to Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

// Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
