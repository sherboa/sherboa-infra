# ==============================================================================
# Sherboa Infrastructure — AWS Security Module
# File: outputs.tf
# Description: Exposes outputs from the AWS security resources.
# ==============================================================================

output "security_group_id" {
  description = "ID of the Sherboa Security Group."
  value       = aws_security_group.sherboa.id
}

output "security_group_arn" {
  description = "ARN of the Sherboa Security Group."
  value       = aws_security_group.sherboa.arn
}
