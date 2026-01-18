variable "role_name" {
  description = "Name of the Lambda execution IAM role."
  type        = string
}

variable "role_description" {
  description = "Description for the Lambda execution IAM role."
  type        = string
  default     = "IAM role assumed by AWS Lambda."
}

variable "attach_vpc_access" {
  description = "Attach AWSLambdaVPCAccessExecutionRole for VPC networking."
  type        = bool
  default     = false
}

variable "attach_xray" {
  description = "Attach AWSXRayDaemonWriteAccess for X-Ray tracing."
  type        = bool
  default     = false
}

variable "attach_lambda_insights" {
  description = "Attach CloudWatchLambdaInsightsExecutionRolePolicy."
  type        = bool
  default     = false
}

variable "additional_policy_arns" {
  description = "Extra IAM policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the IAM role."
  type        = map(string)
  default     = {}
}
