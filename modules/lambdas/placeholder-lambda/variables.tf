variable "function_name" {
  description = "Name of the Lambda function."
  type        = string
}

variable "description" {
  description = "Description for the Lambda function."
  type        = string
  default     = "Placeholder Lambda function."
}

variable "role_arn" {
  description = "IAM role ARN assumed by the Lambda function."
  type        = string
}

variable "runtime" {
  description = "Lambda runtime identifier."
  type        = string
  default     = "python3.11"
}

variable "handler" {
  description = "Handler entrypoint."
  type        = string
  default     = "index.handler"
}

variable "memory_size" {
  description = "Memory size in MB."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout in seconds."
  type        = number
  default     = 3
}

variable "publish" {
  description = "Publish a new version on updates."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment variables for the function."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the Lambda function."
  type        = map(string)
  default     = {}
}
