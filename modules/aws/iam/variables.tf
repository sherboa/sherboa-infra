# ==============================================================================
# Sherboa Infrastructure — AWS IAM Module
# File: variables.tf
# Description: Input variables for IAM resources.
# ==============================================================================

variable "role_name" {
  description = "Name of the EC2 IAM role."
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the EC2 IAM instance profile."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository accessible by the EC2 role."
  type        = string
}

variable "operator_policy_name" {
  description = "Name of the operator SSM access policy."
  type        = string
}

variable "operator_user_name" {
  description = "IAM user receiving the operator SSM access policy."
  type        = string
}

variable "ec2_instance_arn" {
  description = "ARN of the EC2 instance the operator can access."
  type        = string
}

variable "aws_region" {
  description = "AWS region used by the IAM policy."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID."
  type        = string
}
