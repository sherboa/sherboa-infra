# AWS provider configuration for the Terraform state backend bootstrap.
# Credentials are resolved through the standard AWS credential chain.

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "infrastructure"
      ManagedBy   = "Terraform"
      Purpose     = "terraform-state-backend"
    }
  }
}
