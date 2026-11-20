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


# ==============================================================================
# Security
# ==============================================================================

module "security" {
  source = "../../../modules/aws/security"

  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security Group for the Sherboa production EC2 instance."
  vpc_id      = module.networking.vpc_id

  cloudflare_ipv4_cidrs = var.cloudflare_ipv4_cidrs
}


# ==============================================================================
# Compute
# ==============================================================================

module "compute" {
  source = "../../../modules/aws/compute"

  project_name = var.project_name
  environment  = var.environment
  name         = var.instance_name

  subnet_id                 = module.networking.public_subnet_id
  security_group_ids        = [module.security.security_group_id]
  iam_instance_profile_name = var.iam_instance_profile_name

  data_volume_size = var.data_volume_size
}


# ==============================================================================
# IAM
# ==============================================================================

module "iam" {
  source = "../../../modules/aws/iam"

  role_name             = "SherboaEC2Role"
  instance_profile_name = var.iam_instance_profile_name

  ecr_repository_arn = "arn:aws:ecr:us-east-1:557643338880:repository/sherboa-engine"

  operator_policy_name = "SherboaSSMVM02SessionAccess"
  operator_user_name   = "juan"

  ec2_instance_arn = "arn:aws:ec2:us-east-1:557643338880:instance/i-0cbc0ada0ece6db4c"
  aws_region       = "us-east-1"
  aws_account_id   = "557643338880"
}
