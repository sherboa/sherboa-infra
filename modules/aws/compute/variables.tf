# ==============================================================================
# Sherboa Infrastructure — AWS Compute Module
# File: variables.tf
# Description: Defines input variables for the AWS compute resources.
# ==============================================================================

# ------------------------------------------------------------------------------
# General configuration
# ------------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

# ------------------------------------------------------------------------------
# EC2 instance configuration
# ------------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "c8g.large"
}

variable "name" {
  description = "Name assigned to the EC2 instance."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the EC2 instance will be deployed."
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs associated with the EC2 instance."
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile attached to the EC2 instance."
  type        = string
}

# ------------------------------------------------------------------------------
# EBS volume configuration
# ------------------------------------------------------------------------------

variable "root_volume_size" {
  description = "Size of the EC2 root EBS volume in GiB."
  type        = number
  default     = 40
}

variable "data_volume_size" {
  description = "Size of the separate data EBS volume in GiB."
  type        = number
}

