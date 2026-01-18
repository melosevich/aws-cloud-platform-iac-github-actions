############################################################
# Terraform module: GitHub Actions → AWS OIDC IAM Role
#
# This module enables GitHub Actions workflows to authenticate
# to AWS using OpenID Connect (OIDC), without long-lived
# AWS access keys.
#
# It creates:
#  - A GitHub OIDC identity provider (once per AWS account)
#  - An IAM role trusted via OIDC (sts:AssumeRoleWithWebIdentity)
#  - AWS-managed Budgets permissions for FinOps use cases
#
# Authentication (WHO can assume the role):
#  - Controlled by OIDC issuer + aud + sub claims
#
# Authorization (WHAT the role can do):
#  - Controlled by attached IAM policies
############################################################


############################################################
# Provider requirements
############################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}


############################################################
# Local constants
#
# locals are internal constants for this module.
# They are NOT infrastructure resources.
#
# oidc_url defines the identity issuer for GitHub Actions.
############################################################
locals {
  oidc_url = "https://token.actions.githubusercontent.com"
}


############################################################
# TLS certificate lookup
#
# AWS requires a SHA-1 thumbprint for OIDC providers.
# We dynamically fetch GitHub’s TLS certificate so the
# configuration remains valid if GitHub rotates certs.
############################################################
data "tls_certificate" "github_actions" {
  url = local.oidc_url
}


############################################################
# GitHub Actions OIDC provider
#
# This resource registers GitHub Actions as a trusted
# identity provider in the AWS account.
############################################################
resource "aws_iam_openid_connect_provider" "github" {
  url = local.oidc_url

  # Tokens must be intended for AWS STS
  client_id_list = [
    "sts.amazonaws.com"
  ]

  # Cryptographic trust anchor
  thumbprint_list = [
    data.tls_certificate.github_actions.certificates[0].sha1_fingerprint
  ]
}


############################################################
# Assume-role (trust) policy
#
# This policy defines WHO is allowed to assume the role.
# It does NOT grant permissions.
#
# AWS evaluates this during:
#   sts:AssumeRoleWithWebIdentity
############################################################
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    # Required for OIDC federation
    actions = ["sts:AssumeRoleWithWebIdentity"]

    # Trust identities issued by GitHub Actions
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    # Token must be minted specifically for AWS STS
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Restrict WHICH GitHub identity contexts may assume the role
    # Example values:
    #   repo:owner/repo:environment:prod
    #   repo:owner/repo:environment:dev
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_subjects
    }
  }
}


############################################################
# IAM role assumed by GitHub Actions
############################################################
resource "aws_iam_role" "this" {
  name               = var.role_name
  description        = var.role_description
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


############################################################
# Attach AWS-managed Budgets policies
#
# Using AWS-managed policies avoids invalid / undocumented
# Budgets IAM actions and keeps permissions up-to-date.
############################################################

# Allows creating and managing Budgets actions and alerts
resource "aws_iam_role_policy_attachment" "budgets_actions" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBudgetsActionsWithAWSResourceControlAccess"
}

# Allows read-only access to Budgets (useful for reporting)
resource "aws_iam_role_policy_attachment" "budgets_readonly" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBudgetsReadOnlyAccess"
}


############################################################
# Minimal inline policy
#
# Only used for identity verification and debugging.
# Everything else should come from managed policies.
############################################################
data "aws_iam_policy_document" "inline" {
  statement {
    sid       = "StsGetCallerIdentity"
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }

  statement {
    sid       = "IamFullAccess"
    effect    = "Allow"
    actions   = ["iam:*"]
    resources = ["*"]
  }

  statement {
    sid    = "LambdaDeployment"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:AddPermission",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:GetFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:GetFunctionConfiguration",
      "lambda:DeleteFunction",
      "lambda:ListFunctions",
      "lambda:ListVersionsByFunction",
      "lambda:RemovePermission"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3Deployment"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:PutEncryptionConfiguration",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy",
      "s3:DeleteBucketPolicy",
      "s3:GetBucketTagging",
      "s3:PutBucketTagging",
      "s3:GetBucketTagging",
      "s3:PutLifecycleConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EventBridgeRulesAndTargets"
    effect = "Allow"
    actions = [
      "events:PutRule",
      "events:DeleteRule",
      "events:DescribeRule",
      "events:EnableRule",
      "events:DisableRule",
      "events:ListRules",
      "events:PutTargets",
      "events:RemoveTargets",
      "events:ListTargetsByRule",
      "events:TagResource",
      "events:UntagResource",
      "events:ListTagsForResource"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.passrole_arns) > 0 ? [1] : []
    content {
      sid       = "IamPassRole"
      effect    = "Allow"
      actions   = ["iam:PassRole"]
      resources = var.passrole_arns
      condition {
        test     = "StringEquals"
        variable = "iam:PassedToService"
        values   = ["lambda.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role_policy" "inline" {
  name   = "${var.role_name}-identity"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.inline.json
}
