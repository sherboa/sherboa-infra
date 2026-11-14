# ==============================================================================
# Sherboa Infrastructure — AWS Production
# File: main.tf
# Description: Instantiates the AWS infrastructure modules.
# ==============================================================================

module "networking" {
  source = "../../../modules/aws/networking"

  vpc_cidr             = var.vpc_cidr
  project_name         = var.project_name
  environment          = var.environment
  availability_zone_id = var.availability_zone_id
  public_subnet_cidr   = var.public_subnet_cidr
}
