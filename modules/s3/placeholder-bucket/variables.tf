variable "name_prefix" {
  description = "Prefix for the bucket name (account ID is appended)."
  type        = string
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket with all objects."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable bucket versioning."
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Enable S3 block public access settings."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the bucket."
  type        = map(string)
  default     = {}
}
