variable "aws_region" {
  description = "AWS region used by the provider (Budgets is global, but provider needs a region)."
  type        = string
  default     = "eu-central-1"
}

variable "alert_email" {
  description = "Email address to receive AWS Budgets alerts."
  type        = string
}