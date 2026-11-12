# Input variables for the Terraform state backend bootstrap.

variable "aws_region" {
  description = "AWS region where the Terraform state bucket will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource identification and tagging."
  type        = string
  default     = "sherboa"
}

variable "state_bucket_name" {
  description = "Globally unique name for the Terraform state bucket."
  type        = string
}
