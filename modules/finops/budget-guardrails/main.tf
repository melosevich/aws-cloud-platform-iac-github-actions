############################################################
# Terraform module: AWS Budgets (FinOps guardrails)
#
# This module creates a monthly **AWS Cost Budget** and
# configures **email alerts** at configurable thresholds.
#
# Why this exists:
#  - Prevent surprise cloud spend
#  - Provide early warning signals (50/80/100%)
#  - Keep environments (dev/prod) independently controlled
#
# Key behavior:
#  - The AWS Budgets API is **account-scoped**
#  - Terraform must call the Budgets API with an AccountId
#  - We derive the AccountId dynamically from the credentials
#    Terraform is running under (SSO locally, OIDC in CI)
############################################################


############################################################
# Identity lookup (AccountId derivation)
#
# data sources are *reads* (no infrastructure created).
# aws_caller_identity returns the account id + caller ARN
# from the active AWS credentials.
#
# This is critical because Budgets calls must be executed
# against the same account as the credentials being used.
############################################################
data "aws_caller_identity" "current" {}


############################################################
# Monthly Cost Budget
#
# Creates one cost budget per module instance.
#
# IMPORTANT:
# - account_id must match the caller’s AWS account
# - name must be unique per account (Budgets are named)
############################################################
resource "aws_budgets_budget" "monthly_cost" {
  # Budgets API is account-scoped. Use the account Terraform is
  # currently authenticated to (works for SSO + GitHub OIDC).
  account_id = data.aws_caller_identity.current.account_id

  # Budget identity and time scope
  name        = var.name
  budget_type = "COST"
  time_unit   = "MONTHLY"

  # Budget limit
  limit_amount = tostring(var.limit_amount)
  limit_unit   = "USD"

  ##########################################################
  # Alerts / Notifications
  #
  # We define multiple thresholds. AWS will email the listed
  # recipients when ACTUAL spend crosses these percentages
  # of the configured monthly limit.
  #
  # NOTE:
  # - These are ACTUAL cost alerts (not forecast).
  # - Thresholds are percentages of limit_amount.
  ##########################################################

  # Early warning: 50% of budget
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Escalation: 80% of budget
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Critical: 100% of budget
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}