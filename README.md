# AWS Cloud Platform IaC – GitHub Actions + OIDC

This repository contains the Infrastructure as Code (IaC) setup for an AWS cloud platform using Terraform and GitHub Actions with AWS OIDC authentication.

The architecture follows a deliberate and realistic lifecycle that reflects real-world AWS security and trust constraints. In particular, day-zero bootstrap is manual by design and intentionally kept outside CI/CD.

---

## Design principles

- No long-lived AWS credentials stored in CI/CD
- GitHub Actions authenticate to AWS using OIDC
- Clear separation between manual bootstrap and automated provisioning
- Reusable Terraform modules
- Strict environment and region isolation
- Predictable, low-risk infrastructure lifecycle

---

## Repository structure

aws-cloud-platform-iac-github-actions
├── README.md
├── modules
│   ├── finops-budget
│   └── github-oidc-role
└── states
    ├── dev
    │   ├── bootstrap
    │   ├── base
    │   └── eu-central-1
    └── prod
        ├── bootstrap
        ├── base
        └── eu-central-1

Modules contain reusable Terraform components.
States contain environment- and region-specific Terraform configurations.

---

## Lifecycle overview

The platform is built and operated in clearly separated phases.

### Phase 0 — Manual bootstrap (one-time, outside GitHub Actions)

This repository assumes that an initial manual bootstrap has already been completed.

This step cannot be automated on day zero because:
- No Terraform backend exists yet
- No trust relationship exists between GitHub and AWS
- GitHub Actions cannot assume an IAM role that does not yet exist

The following resources are created manually, once per AWS account:

- S3 bucket for Terraform remote state
- DynamoDB table for Terraform state locking
- IAM OIDC provider for GitHub Actions
- Initial IAM role(s) that GitHub Actions will later assume

This step is intentionally performed outside GitHub Actions using elevated or temporary credentials and is not part of this repository’s automated workflows.

---

### Phase 1 — Environment bootstrap (states/*/bootstrap)

Purpose:
- Establish environment-level foundations
- Prepare the account for safe automation

Typical contents:
- IAM policies
- Guardrails
- Account or organization-level configuration

Execution characteristics:
- Per environment (dev, prod, etc.)
- Usually applied manually or with elevated permissions
- Very low change frequency

---

### Phase 2 — Base infrastructure (states/*/base)

Purpose:
- Shared infrastructure used across all regions
- Stable, low-churn components

Typical contents:
- AWS Budgets and FinOps controls
- Shared IAM roles
- Monitoring foundations

Execution characteristics:
- Automated via GitHub Actions
- Uses OIDC-assumed roles
- Safe once backend and trust are in place

---

### Phase 3 — Regional infrastructure (states/*/<region>)

Purpose:
- Region-scoped and workload-specific infrastructure

Typical contents:
- Regional services
- Environment-specific resources

Execution characteristics:
- Fully automated
- CI/CD driven
- Uses GitHub Actions with OIDC authentication

---

## Terraform modules

### github-oidc-role

Creates IAM roles that can be assumed by GitHub Actions using OpenID Connect.

Benefits:
- No stored AWS secrets
- Short-lived credentials
- AWS-native authentication model

---

### finops-budget

Encapsulates AWS Budgets and cost control logic.

Benefits:
- Reusable across environments
- Centralized FinOps configuration
- Clear separation of policy and usage

---

## Summary

This repository intentionally separates trust establishment from automation.

Manual bootstrap is a one-time prerequisite that enables:
- Secure GitHub Actions authentication
- Safe and repeatable Terraform automation
- Clear operational boundaries

Once bootstrap is complete, all base and regional infrastructure can be managed fully through GitHub Actions using short-lived, auditable credentials.