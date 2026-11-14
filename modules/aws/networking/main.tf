# ==============================================================================
# Sherboa Infrastructure — AWS Networking
# File: main.tf
# Description: Defines the VPC and Internet Gateway for AWS networking.
# ==============================================================================


# Virtual Private Cloud (VPC): Provides an isolated virtual network for Sherboa AWS infrastructure.
# Defines the private IP address space and network boundaries for AWS resources.
resource "aws_vpc" "sherboa" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# Internet Gateway (IGW): Provides internet connectivity for the Sherboa VPC.
resource "aws_internet_gateway" "sherboa" {
  vpc_id = aws_vpc.sherboa.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}


# Public Subnet: Provides a public network segment within the Sherboa VPC.
# Automatically assigns public IPv4 addresses to launched instances.
resource "aws_subnet" "public" {
  vpc_id               = aws_vpc.sherboa.id
  availability_zone_id = var.availability_zone_id
  cidr_block           = var.public_subnet_cidr

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# Public Route Table: Defines routing rules for the Sherboa public subnet.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.sherboa.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Default Route: Routes outbound internet traffic through the Internet Gateway.
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sherboa.id
}

# Route Table Association: Associates the public route table with the public subnet.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
