# ==============================================================================
# Sherboa Infrastructure — AWS Production
# File: outputs.tf
# Description: Exposes outputs from the production infrastructure.
# ==============================================================================

output "vpc_id" {
  description = "ID of the production VPC."
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the production VPC."
  value       = module.networking.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "ID of the production Internet Gateway."
  value       = module.networking.internet_gateway_id
}

output "public_subnet_id" {
  description = "ID of the production public subnet."
  value       = module.networking.public_subnet_id
}

output "public_subnet_cidr_block" {
  description = "CIDR block assigned to the production public subnet."
  value       = module.networking.public_subnet_cidr_block
}

output "public_route_table_id" {
  description = "ID of the production public route table."
  value       = module.networking.public_route_table_id
}
