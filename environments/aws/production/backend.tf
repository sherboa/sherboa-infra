# S3 remote backend configuration for AWS production.
# State locking uses Terraform's native S3 lockfile mechanism.

terraform {
  backend "s3" {
    bucket       = "sherboa-terraform-state-557643338880-us-east-1"
    key          = "aws/production/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
