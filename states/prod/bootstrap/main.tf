module "github_oidc_role" {
  source = "../../../modules/iam/github-oidc-role"

  role_name        = "GitHubActionsRoleProd"
  role_description = "OIDC role assumed by GitHub Actions (prod)"

  github_subjects = [
    "repo:gonzalo-labs/aws-cloud-platform-iac-github-actions:environment:prod",
    "repo:gonzalo-labs/aws-lambda-data-ingestion:environment:prod"
  ]
}