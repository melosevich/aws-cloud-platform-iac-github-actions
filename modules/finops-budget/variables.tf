variable "name" {
  description = "Budget name."
  type        = string
}

variable "limit_amount" {
  description = "Monthly budget amount in USD."
  type        = number
}

variable "alert_email" {
  description = "Email address to receive AWS Budgets alerts."
  type        = string
}