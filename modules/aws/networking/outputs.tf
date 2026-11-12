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
