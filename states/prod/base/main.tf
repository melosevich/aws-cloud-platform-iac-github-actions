module "finops_budget" {
  source = "../../../modules/finops/budget-guardrails"

  name         = "dev-finops-monthly-budget"
  limit_amount = 50
  alert_email  = var.alert_email
}