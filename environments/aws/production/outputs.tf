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

output "security_group_id" {
  description = "ID of the production Security Group."
  value       = module.security.security_group_id
}

output "security_group_arn" {
  description = "ARN of the production Security Group."
  value       = module.security.security_group_arn
}


# ------------------------------------------------------------------------------
# Compute outputs
# ------------------------------------------------------------------------------

output "instance_id" {
  description = "ID of the production EC2 instance."
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "Public IP address of the production EC2 instance."
  value       = module.compute.instance_public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the production EC2 instance."
  value       = module.compute.instance_private_ip
}

output "data_volume_id" {
  description = "ID of the separate production data EBS volume."
  value       = module.compute.data_volume_id
}
