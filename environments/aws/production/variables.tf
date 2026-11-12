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
