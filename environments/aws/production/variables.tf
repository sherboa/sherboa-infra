# ==============================================================================
# Sherboa Infrastructure — AWS Production
# File: variables.tf
# Description: Declares input variables for the production environment.
# ==============================================================================

variable "aws_region" {
  description = "AWS region where the production infrastructure will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource identification and tagging."
  type        = string
  default     = "sherboa"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the production VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_id" {
  description = "Availability Zone ID for the public subnet."
  type        = string
  default     = "use1-az1"
}

variable "public_subnet_cidr" {
  description = "CIDR block assigned to the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}


# ------------------------------------------------------------------------------
# Security configuration
# ------------------------------------------------------------------------------

variable "cloudflare_ipv4_cidrs" {
  description = "Cloudflare IPv4 CIDR ranges allowed to access the production origin."
  type        = set(string)
}


# ------------------------------------------------------------------------------
# Compute configuration
# ------------------------------------------------------------------------------

variable "instance_name" {
  description = "Name assigned to the production EC2 instance."
  type        = string
  default     = "sherboa-vm-02"
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile attached to the EC2 instance."
  type        = string
  default     = "SherboaEC2InstanceProfile"
}

variable "data_volume_size" {
  description = "Size of the separate data EBS volume in GiB."
  type        = number
}
