# ==============================================================================
# Sherboa Infrastructure — AWS Security Module
# File: main.tf
# Description: Provisions the Security Group and its access rules.
# ==============================================================================

# ------------------------------------------------------------------------------
# Security Group
# ------------------------------------------------------------------------------

resource "aws_security_group" "sherboa" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  # Inbound and outbound rules are managed through dedicated resources.
  # This avoids mixing inline rules with standalone security group rules.

  tags = {
    Name = var.name
  }
}

# ------------------------------------------------------------------------------
# Inbound HTTP — Cloudflare IPv4
# ------------------------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = var.cloudflare_ipv4_cidrs

  security_group_id = aws_security_group.sherboa.id

  description = "HTTP from Cloudflare IPv4"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = each.value
}

# ------------------------------------------------------------------------------
# Inbound HTTPS — Cloudflare IPv4
# ------------------------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = var.cloudflare_ipv4_cidrs

  security_group_id = aws_security_group.sherboa.id

  description = "HTTPS from Cloudflare IPv4"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = each.value
}

# ------------------------------------------------------------------------------
# Outbound — All IPv4 traffic
# ------------------------------------------------------------------------------

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.sherboa.id

  description = "Allow all outbound IPv4 traffic"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
