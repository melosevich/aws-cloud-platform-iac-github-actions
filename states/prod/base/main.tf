module "finops_budget" {
  source = "../../../modules/finops/budget-guardrails"

  name         = "prod-finops-monthly-budget"
  limit_amount = 50
  alert_email  = var.alert_email
}

module "lambda_execution_role" {
  source = "../../../modules/iam/lambda-execution-role"

  role_name        = "LambdaExecutionRoleProd"
  role_description = "IAM role assumed by AWS Lambda (prod)"
}
