variable "aws_region" {
  description = "AWS region for regional resources (even if this stack is mostly global)."
  type        = string
  default     = "eu-central-1"
}

variable "alert_email" {
  description = "Email used for AWS Budgets notifications."
  type        = string
}