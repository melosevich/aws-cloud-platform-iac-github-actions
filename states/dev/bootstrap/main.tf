module "github_oidc_role" {
  source = "../../../modules/github-oidc-role"

  role_name        = "GitHubActionsFinOpsRoleDev"
  role_description = "OIDC role assumed by GitHub Actions (dev)"

  github_subjects = [
    "repo:gonzalo-labs/aws-cloud-platform-iac-github-actions:environment:dev"
  ]
}