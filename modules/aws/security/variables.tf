# ==============================================================================
# Sherboa Infrastructure — AWS Security Module
# File: variables.tf
# Description: Defines input variables for the AWS security resources.
# ==============================================================================

# ------------------------------------------------------------------------------
# Security Group configuration
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name assigned to the Security Group."
  type        = string
}

variable "description" {
  description = "Description of the Security Group."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the Security Group will be created."
  type        = string
}

# ------------------------------------------------------------------------------
# Cloudflare configuration
# ------------------------------------------------------------------------------

variable "cloudflare_ipv4_cidrs" {
  description = "List of Cloudflare IPv4 CIDR ranges allowed to access the application."
  type        = set(string)

  validation {
    condition     = length(var.cloudflare_ipv4_cidrs) > 0
    error_message = "At least one Cloudflare IPv4 CIDR range must be provided."
  }
}
