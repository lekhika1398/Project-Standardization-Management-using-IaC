# Azure Terraform Governance Template

Production-ready Azure governance template using Terraform, Azure Policy, and GitHub Actions with OIDC.

## Deployment Index

1. OIDC service principal setup: `docs/deployment.md`
2. Backend bootstrap workflow: `.github/workflows/backend-setup.yml`
3. Governance operations workflow: `.github/workflows/terraform-governance.yml`
4. Runtime operation usage and scope switching: `docs/how-to-use.md`
5. Policy extension model: `policies/README.md`
6. Security posture summary: `docs/security/security-analytics-report.md`

## What This Template Delivers

- Modular policy-as-code architecture
- Auto-discovery of policies from `policies/*/definition.json`
- Selectable policy assignment scope:
  - `resource_group`
  - `subscription`
  - `management_group`
- Governance resource group support (`Lekhika_RG` default)
- Optional free App Service deployment (F1)
- Manual run workflow with operation choice: `plan`, `apply`, `destroy`
- Approval-gated apply and destroy using GitHub Environments
- Dedicated backend setup workflow that creates remote state resources and prints required backend values

## Repository Structure

```text
azure-terraform-governance-template/
├── main.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars.example
├── outputs.tf
├── backend.tf
├── dev.tfvars
├── preflight.sh
├── modules/
│   ├── naming/
│   ├── resource-group/
│   ├── app-service/
│   └── policy-engine/
│       ├── variables.tf
│       ├── locals.tf
│       ├── definitions.tf
│       ├── assignments.tf
│       └── outputs.tf
├── policies/
│   ├── tagging/
│   ├── naming/
│   └── README.md
├── scripts/
│   └── preflight.sh
├── .github/
│   └── workflows/
│       ├── backend-setup.yml
│       └── terraform-governance.yml
├── docs/
│   ├── deployment.md
│   ├── how-to-use.md
│   └── security/
│       └── security-analytics-report.md
└── README.md
```

## Required GitHub Values

Set these as **Repository Variables or Secrets**:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT`
- `TFSTATE_CONTAINER`
- `TFSTATE_KEY`

Note: You do not need to create any `ARM_*` repository values. Workflows use only `AZURE_*` and `TFSTATE_*` inputs.

Set these as **Repository Variables** (defaults for runtime):

- `TF_VAR_ORG_PREFIX`
- `TF_VAR_ENVIRONMENT`
- `TF_VAR_REGION_CODE`
- `TF_VAR_LOCATION`

Optional default variables:

- `TF_VAR_POLICY_SCOPE_TYPE`
- `TF_VAR_MANAGEMENT_GROUP_ID`
- `TF_VAR_GOVERNANCE_RG_NAME`
- `TF_VAR_CREATE_GOVERNANCE_RG`
- `TF_VAR_DEPLOY_FREE_APP_SERVICE`
- `TF_VAR_APP_SERVICE_NAME_PREFIX`

## Quick Start

1. Configure OIDC values (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`).
2. Run `Backend Setup` workflow and copy backend outputs.
3. Save backend outputs as `TFSTATE_*` repository values.
4. Use `dev.tfvars` for default dev deployment profile (creates RG and assigns policies at that RG scope).
5. Configure `TF_VAR_*` defaults (or pass at runtime when triggering workflow).
6. Run `Terraform Governance` workflow and choose operation:
   - `plan`
   - `apply` (workflow runs plan first, then approval required in `terraform-apply` environment)
   - `destroy` (workflow runs destroy plan first, then approval required in `terraform-destroy` environment)
7. Keep `tfvars_file` input as `dev.tfvars` for dev runs, or change it for other profiles.

## Scope Guidance

- `resource_group`: targeted governance rollout for one RG.
- `subscription`: baseline across subscription.
- `management_group`: governance at scale across subscriptions.

Use `subscription` or `management_group` scope for resource-group naming policy enforcement.
