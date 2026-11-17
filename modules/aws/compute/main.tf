# ==============================================================================
# Sherboa Infrastructure — AWS Compute Module
# File: main.tf
# Description: Provisions the EC2 instance and its EBS storage volumes.
# ==============================================================================

# ------------------------------------------------------------------------------
# Subnet information
# ------------------------------------------------------------------------------

data "aws_subnet" "selected" {
  id = var.subnet_id
}

# ------------------------------------------------------------------------------
# Ubuntu AMI — Canonical
# ------------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-arm64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------------------
# EC2 instance
# ------------------------------------------------------------------------------

resource "aws_instance" "sherboa" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile_name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  user_data = templatefile(
    "${path.module}/scripts/mount-data-volume.sh.tftpl",
    {
      data_volume_id = aws_ebs_volume.data.id
    }
  )

  tags = {
    Name        = var.name
    Project     = var.project_name
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# Data EBS volume
# ------------------------------------------------------------------------------

resource "aws_ebs_volume" "data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = var.data_volume_size
  type              = "gp3"
  encrypted         = true

  tags = {
    Name        = "${var.name}-data"
    Project     = var.project_name
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}

# ------------------------------------------------------------------------------
# Data EBS volume attachment
# ------------------------------------------------------------------------------

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.sherboa.id
}
