# Azure Terraform Governance Template

Enterprise-ready Terraform template for Azure subscription governance with modular policy-as-code, naming standardization, and GitHub Actions CI/CD using OIDC.

## Key Capabilities

- Subscription-scope Azure Policy deployment and assignment
- Mandatory tag and naming convention deny controls
- Dynamic policy discovery from `policies/*/definition.json`
- Reusable naming module for standardized resource names
- Optional sample resource group deployment for validation
- GitHub Actions workflow for PR plan and main-branch apply

## Repository Structure

```text
azure-terraform-governance-template/
├── main.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars.example
├── outputs.tf
├── backend.tf
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
│       └── terraform-governance.yml
├── security/
│   └── security-analytics-report.md
├── deployment.md
└── README.md
```

## Quick Start

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Use `deployment.md` for full enterprise deployment steps, OIDC setup, backend configuration, and validation procedures.
