# AWS provider configuration for the production environment.
# Credentials are resolved through the standard AWS credential chain.

provider "aws" {
  region = var.aws_region

  # Apply common tags to all supported AWS resources.
  default_tags {
    tags = {
      Project     = "sherboa"
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}