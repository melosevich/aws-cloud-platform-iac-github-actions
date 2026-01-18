module "finops_budget" {
  source = "../../../modules/finops/budget-guardrails"

  name         = "dev-finops-monthly-budget"
  limit_amount = 50
  alert_email  = var.alert_email
}

module "lambda_execution_role" {
  source = "../../../modules/iam/lambda-execution-role"

  role_name        = "LambdaExecutionRoleDev"
  role_description = "IAM role assumed by AWS Lambda (dev)"
}
