# ==============================================================================
# Sherboa Infrastructure — AWS IAM Module
# File: main.tf
# Description: Manages IAM resources for Sherboa EC2 and operator access.
# ==============================================================================

# ------------------------------------------------------------------------------
# EC2 Role
# ------------------------------------------------------------------------------

resource "aws_iam_role" "ec2" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# EC2 Instance Profile
# ------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "ec2" {
  name = var.instance_profile_name
  role = aws_iam_role.ec2.name
}

# ------------------------------------------------------------------------------
# EC2 Managed Policy Attachments
# ------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ------------------------------------------------------------------------------
# EC2 ECR Pull Policy
# ------------------------------------------------------------------------------

resource "aws_iam_role_policy" "ecr_pull" {
  name = "SherboaEC2EcrPullPolicy"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EcrLogin"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "EcrPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = var.ecr_repository_arn
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# Operator SSM Access Policy
# ------------------------------------------------------------------------------

resource "aws_iam_policy" "operator_ssm_access" {
  name        = var.operator_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DescribeManagedInstances"
        Effect   = "Allow"
        Action   = ["ssm:DescribeInstanceInformation"]
        Resource = "*"
      },
      {
        Sid    = "StartSessionOnVM02"
        Effect = "Allow"
        Action = ["ssm:StartSession"]
        Resource = [
          var.ec2_instance_arn,
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:document/SSM-SessionManagerRunShell"
        ]
      },
      {
        Sid    = "ManageOwnSessions"
        Effect = "Allow"
        Action = [
          "ssm:ResumeSession",
          "ssm:TerminateSession",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "arn:aws:ssm:*:*:session/$${aws:userid}-*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "operator_ssm_access" {
  user       = var.operator_user_name
  policy_arn = aws_iam_policy.operator_ssm_access.arn
}
