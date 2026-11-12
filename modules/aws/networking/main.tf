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
