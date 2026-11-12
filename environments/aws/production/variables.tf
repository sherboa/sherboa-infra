# Input variables for the AWS production environment.
# Define shared configuration values used across the Terraform resources.

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