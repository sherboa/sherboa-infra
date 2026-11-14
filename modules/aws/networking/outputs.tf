# ==============================================================================
# Sherboa Infrastructure — AWS Networking
# File: outputs.tf
# Description: Exposes outputs from the AWS networking module.
# ==============================================================================

output "vpc_id" {
  description = "ID of the Sherboa VPC."
  value       = aws_vpc.sherboa.id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the Sherboa VPC."
  value       = aws_vpc.sherboa.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Sherboa Internet Gateway."
  value       = aws_internet_gateway.sherboa.id
}

output "public_subnet_id" {
  description = "ID of the Sherboa public subnet."
  value       = aws_subnet.public.id
}

output "public_subnet_cidr_block" {
  description = "CIDR block assigned to the Sherboa public subnet."
  value       = aws_subnet.public.cidr_block
}

output "public_route_table_id" {
  description = "ID of the Sherboa public route table."
  value       = aws_route_table.public.id
}
