module "github_oidc_role" {
  source = "../../../modules/github-oidc-role"

  role_name        = "GitHubActionsFinOpsRoleProd"
  role_description = "OIDC role assumed by GitHub Actions (prod)"

  github_subjects = [
    "repo:melosevich/aws-cloud-platform-iac-github-actions:environment:prod"
  ]
}