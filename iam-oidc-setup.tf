# This file creates the IAM role for GitHub Actions OIDC
# Run this once manually to set up OIDC authentication

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# Get AWS account ID
data "aws_caller_identity" "current" {}

# OIDC Identity Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
  
  client_id_list = [
    "sts.amazonaws.com"
  ]
  
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
  
  tags = {
    Name        = "GitHub Actions OIDC Provider"
    Owner       = "Joshua-Agyekum"
    Purpose     = "GitHub-Actions-Authentication"
    ManagedBy   = "Terraform"
  }
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "GitHubActionsRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Kofijoo/terraform-aws-deployment:*"
          }
        }
      }
    ]
  })
  
  tags = {
    Name        = "GitHub Actions Role"
    Owner       = "Joshua-Agyekum"
    Purpose     = "GitHub-Actions-Deployment"
    ManagedBy   = "Terraform"
  }
}

# IAM Policy for Terraform operations
resource "aws_iam_policy" "github_actions_terraform" {
  name        = "GitHubActionsTerraformPolicy"
  description = "Policy for GitHub Actions to manage Terraform infrastructure"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "vpc:*",
          "elasticloadbalancing:*",
          "iam:*",
          "s3:*",
          "dynamodb:*",
          "route53:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "github_actions_terraform" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_terraform.arn
}

# Outputs
output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = aws_iam_role.github_actions.arn
}

output "aws_account_id" {
  description = "AWS Account ID for GitHub secrets"
  value       = data.aws_caller_identity.current.account_id
}