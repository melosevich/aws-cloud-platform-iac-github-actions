module "github_oidc_role" {
  source = "../../../modules/iam/github-oidc-role"

  role_name        = "GitHubActionsRoleDev"
  role_description = "OIDC role assumed by GitHub Actions (dev)"

  github_subjects = [
    "repo:gonzalo-labs/aws-cloud-platform-iac-github-actions:environment:dev",
    "repo:gonzalo-labs/aws-lambda-data-ingestion:environment:dev"
  ]
}