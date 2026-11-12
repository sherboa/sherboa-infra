# Terraform and provider version requirements.
# Keep Terraform below the next major release and use AWS provider 6.x.

terraform {
  required_version = ">= 1.17.2, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.71"
    }
  }
}