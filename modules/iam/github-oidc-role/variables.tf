############################################################
# Variables for GitHub Actions OIDC Role module
############################################################

# Name of the IAM role to create
variable "role_name" {
  type        = string
  description = "IAM role name for GitHub Actions OIDC federation"
  default     = "GitHubActionsRole"
}

# Optional description for the role
variable "role_description" {
  type        = string
  description = "Description of the GitHub Actions OIDC IAM role"
  default     = "OIDC role assumed by GitHub Actions"
}

# List of allowed GitHub OIDC subject claims (sub)
#
# Examples:
#   - repo:owner/repo:environment:prod
#   - repo:owner/repo:environment:dev
#   - repo:owner/repo:ref:refs/heads/main
#
# These values directly control WHO can assume the role.
variable "github_subjects" {
  type        = list(string)
  description = "Allowed GitHub OIDC subject claims (sub)"
}