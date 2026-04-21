# modules/github-oidc/main.tf
#
# GitHub Actions OIDC provider and deployment role.
# The OIDC provider is account-level (one per account). Set create_oidc_provider = false
# in additional environments (e.g., prod) and this module will reference the existing one.

data "aws_caller_identity" "current" {}

# OIDC Provider (created once per AWS account)
resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create_oidc_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
  account_id        = data.aws_caller_identity.current.account_id
}

# IAM Role — assumed by GitHub Actions via OIDC
resource "aws_iam_role" "github_deploy" {
  name = "github-deploy-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Scoped to the GitHub environment (set on the deploy job)
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:environment:${var.environment}"
        }
      }
    }]
  })
}

# Inline policy — least-privilege permissions for deploying this project
resource "aws_iam_role_policy" "github_deploy" {
  name = "github-deploy-policy-${var.environment}"
  role = aws_iam_role.github_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR auth is account-level, not resource-scoped
      {
        Sid      = "ECRAuth"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      # ECR repository — push images + Terraform lifecycle management
      {
        Sid    = "ECRRepository"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:ListTagsForResource",
          "ecr:PutImage",
          "ecr:PutImageScanningConfiguration",
          "ecr:PutImageTagMutability",
          "ecr:TagResource",
          "ecr:UntagResource",
          "ecr:UploadLayerPart"
        ]
        Resource = "arn:aws:ecr:${var.region}:${local.account_id}:repository/lift-model-${var.environment}"
      },
      # Lambda function management
      {
        Sid    = "Lambda"
        Effect = "Allow"
        Action = [
          "lambda:AddPermission",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:InvokeFunction",
          "lambda:ListTags",
          "lambda:ListVersionsByFunction",
          "lambda:PublishVersion",
          "lambda:RemovePermission",
          "lambda:TagResource",
          "lambda:UntagResource",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration"
        ]
        Resource = "arn:aws:lambda:${var.region}:${local.account_id}:function:calculate_lift_${var.environment}"
      },
      # IAM — OIDC provider lookup (account-level list/get) + manage Lambda role/policy
      {
        Sid    = "IAMOIDCRead"
        Effect = "Allow"
        Action = [
          "iam:ListOpenIDConnectProviders",
          "iam:GetOpenIDConnectProvider"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMRolePolicy"
        Effect = "Allow"
        Action = [
          "iam:AttachRolePolicy",
          "iam:CreatePolicy",
          "iam:CreateRole",
          "iam:DeletePolicy",
          "iam:DeleteRole",
          "iam:DetachRolePolicy",
          "iam:Get*",
          "iam:List*",
          "iam:PassRole",
          "iam:TagPolicy",
          "iam:TagRole",
          "iam:UntagPolicy",
          "iam:UntagRole"
        ]
        Resource = [
          "arn:aws:iam::${local.account_id}:role/lift-model-role-${var.environment}",
          "arn:aws:iam::${local.account_id}:policy/lift-model-s3-read-${var.environment}"
        ]
      },
      # S3 — data bucket (Get*/List* covers all read variants Terraform needs during refresh)
      {
        Sid    = "S3Data"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:DeleteObject",
          "s3:Get*",
          "s3:List*",
          "s3:PutBucketTagging",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.data_bucket_name}",
          "arn:aws:s3:::${var.data_bucket_name}/*"
        ]
      },
      # S3 — Terraform state bucket
      {
        Sid    = "TerraformState"
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:Get*",
          "s3:List*",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::cmpex-tfstate",
          "arn:aws:s3:::cmpex-tfstate/*"
        ]
      },
      # CloudWatch Logs — Lambda log group
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups",
          "logs:ListTagsLogGroup",
          "logs:TagLogGroup",
          "logs:UntagLogGroup"
        ]
        Resource = "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/lambda/calculate_lift_${var.environment}*"
      }
    ]
  })
}
