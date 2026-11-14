# ==============================================================================
# Sherboa Infrastructure — AWS Networking
# File: variables.tf
# Description: Declares input variables for the networking module.
# ==============================================================================

variable "vpc_cidr" {
  description = "CIDR block assigned to the Sherboa VPC."
  type        = string
}

variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "availability_zone_id" {
  description = "Availability Zone ID for the public subnet."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block assigned to the public subnet."
  type        = string
}
