# ==============================================================================
# Sherboa Infrastructure — AWS Production
# File: main.tf
# Description: Instantiates the AWS infrastructure modules.
# ==============================================================================

module "networking" {
  source = "../../../modules/aws/networking"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
}
