# ==============================================================================
# Sherboa Infrastructure — AWS Compute Module
# File: outputs.tf
# Description: Exposes outputs from the AWS compute resources.
# ==============================================================================

output "instance_id" {
  description = "ID of the Sherboa EC2 instance."
  value       = aws_instance.sherboa.id
}

output "instance_arn" {
  description = "ARN of the Sherboa EC2 instance."
  value       = aws_instance.sherboa.arn
}

output "instance_public_ip" {
  description = "Public IP address of the Sherboa EC2 instance."
  value       = aws_instance.sherboa.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the Sherboa EC2 instance."
  value       = aws_instance.sherboa.private_ip
}

output "availability_zone" {
  description = "Availability Zone where the EC2 instance is deployed."
  value       = aws_instance.sherboa.availability_zone
}

output "data_volume_id" {
  description = "ID of the separate data EBS volume."
  value       = aws_ebs_volume.data.id
}

output "data_volume_arn" {
  description = "ARN of the separate data EBS volume."
  value       = aws_ebs_volume.data.arn
}
