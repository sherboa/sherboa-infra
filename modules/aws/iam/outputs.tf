# ==============================================================================
# Sherboa Infrastructure — AWS IAM Module
# File: outputs.tf
# Description: Exposes IAM resource identifiers.
# ==============================================================================

output "role_arn" {
  description = "ARN of the EC2 IAM role."
  value       = aws_iam_role.ec2.arn
}

output "role_name" {
  description = "Name of the EC2 IAM role."
  value       = aws_iam_role.ec2.name
}

output "instance_profile_name" {
  description = "Name of the EC2 instance profile."
  value       = aws_iam_instance_profile.ec2.name
}

output "operator_policy_arn" {
  description = "ARN of the operator SSM access policy."
  value       = aws_iam_policy.operator_ssm_access.arn
}
