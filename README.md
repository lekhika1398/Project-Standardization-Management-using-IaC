# Azure Terraform Governance Template

Production-ready Azure governance template using Terraform, Azure Policy, and GitHub Actions with OIDC.

## Deployment Index

1. Backend bootstrap workflow: `.github/workflows/backend-setup.yml`
2. Service principal and OIDC setup: `deployment.md`
3. GitHub variables setup: `deployment.md`
4. Governance deployment pipeline: `.github/workflows/terraform-governance.yml`
5. Template usage and scope switch: `how-to-use.md`
6. Policy authoring and scaling: `policies/README.md`

## What This Template Delivers

- Modular policy-as-code architecture
- Auto-discovery of policies from `policies/*/definition.json`
- Policy assignment scope selectable by user:
  - `resource_group`
  - `subscription`
  - `management_group`
- Governance resource group support (`Lekhika_RG` default)
- Optional free App Service deployment (F1)
- CI/CD pipeline with Terraform plan on PR and apply on `main`
- Dedicated backend setup workflow to create and publish state configuration values

## Repository Structure

```text
azure-terraform-governance-template/
├── main.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars.example
├── outputs.tf
├── backend.tf
├── preflight.sh
├── modules/
│   └── naming/
│       ├── variables.tf
│       ├── locals.tf
│       └── outputs.tf
├── policies/
│   ├── tagging/
│   │   ├── definition.json
│   │   └── policy.tf
│   ├── naming/
│   │   ├── definition.json
│   │   └── policy.tf
│   └── README.md
├── resources/
│   └── resource-group.tf
├── .github/
│   └── workflows/
│       ├── backend-setup.yml
│       └── terraform-governance.yml
├── security/
│   └── security-analytics-report.md
├── how-to-use.md
├── deployment.md
└── README.md
```

## Required GitHub Repository Variables

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT`
- `TFSTATE_CONTAINER`
- `TFSTATE_KEY`
- `TF_VAR_ORG_PREFIX`
- `TF_VAR_ENVIRONMENT`
- `TF_VAR_REGION_CODE`
- `TF_VAR_LOCATION`

Optional repository variables:

- `TF_VAR_POLICY_SCOPE_TYPE`
- `TF_VAR_MANAGEMENT_GROUP_ID`
- `TF_VAR_GOVERNANCE_RG_NAME`
- `TF_VAR_CREATE_GOVERNANCE_RG`
- `TF_VAR_DEPLOY_FREE_APP_SERVICE`
- `TF_VAR_APP_SERVICE_NAME_PREFIX`

## Quick Start

1. Configure OIDC variables (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`).
2. Run **Backend Setup** workflow to create remote state backend.
3. Add backend outputs to repository variables.
4. Add required `TF_VAR_*` repository variables.
5. Open PR to `main` to run Terraform plan.
6. Merge PR to trigger apply.

## Scope Guidance

- `resource_group`: targeted governance rollout for one RG.
- `subscription`: standard enterprise baseline across subscription.
- `management_group`: multi-subscription governance at scale.

Use `subscription` or `management_group` for resource-group naming policy enforcement.

## Documentation Index

- `deployment.md`: end-to-end setup with exact commands
- `how-to-use.md`: daily usage, scope changes, and operations
- `policies/README.md`: how to add unlimited policies
- `security/security-analytics-report.md`: governance control analysis
