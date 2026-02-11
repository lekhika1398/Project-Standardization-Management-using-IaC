# Azure Governance Deployment Guide

## 1. Prerequisites

- Azure subscription and tenant access
- GitHub repository with Actions enabled
- Permission to create Entra app registrations and role assignments
- Terraform backend will be created by workflow `.github/workflows/backend-setup.yml`

## 2. Create Service Principal and OIDC Federation

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"

SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
TENANT_ID="$(az account show --query tenantId -o tsv)"
APP_NAME="gh-terraform-governance"
GITHUB_ORG="<GITHUB_ORG>"
GITHUB_REPO="<GITHUB_REPO>"

APP_ID="$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)"
SP_OBJECT_ID="$(az ad sp create --id "$APP_ID" --query id -o tsv)"

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters "{\"name\":\"github-main\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_ORG}/${GITHUB_REPO}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters "{\"name\":\"github-terraform-ops-env\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_ORG}/${GITHUB_REPO}:environment:terraform-ops\",\"audiences\":[\"api://AzureADTokenExchange\"]}"
```

## 3. Configure Core GitHub Values

Set these repository values (variables or secrets):

- `AZURE_CLIENT_ID` = `<APP_ID>`
- `AZURE_TENANT_ID` = `<TENANT_ID>`
- `AZURE_SUBSCRIPTION_ID` = `<SUBSCRIPTION_ID>`

No separate `ARM_*` repository values are required.

## 4. Run Backend Setup Workflow

Run **Backend Setup** workflow with inputs:

- `location`
- `backend_resource_group`
- `storage_account_prefix`
- `container_name`
- `state_key`

Copy output values from workflow summary and set:

- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT`
- `TFSTATE_CONTAINER`
- `TFSTATE_KEY`

## 5. Grant Backend Access

```bash
RG_NAME="<TFSTATE_RESOURCE_GROUP>"
SA_NAME="<TFSTATE_STORAGE_ACCOUNT>"

SA_ID="$(az storage account show --name "$SA_NAME" --resource-group "$RG_NAME" --query id -o tsv)"

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope "$SA_ID"
```

## 6. Assign Governance Roles By Scope

Resource-group scope (`Lekhika_RG`) example:

```bash
RG_NAME="Lekhika_RG"

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Resource Policy Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME"

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME"
```

Subscription scope example:

```bash
az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Resource Policy Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

Management-group scope example:

```bash
MG_ID="<MANAGEMENT_GROUP_ID>"

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Resource Policy Contributor" \
  --scope "/providers/Microsoft.Management/managementGroups/$MG_ID"
```

## 7. Configure Terraform Values

Set deployment values in your tfvars file (for example `dev.tfvars`), including:

- `org_prefix`
- `environment`
- `region_code`
- `location`
- `policy_scope_type`
- `management_group_id` (when needed)
- `governance_resource_group_name`
- `create_governance_resource_group`
- `deploy_free_app_service`
- `app_service_plan_sku_name`
- `app_service_name_prefix`

## 8. Configure Approval Gates

Create GitHub environment:

- `terraform-ops`

Add required reviewers so apply/destroy pause for approval.

## 9. Run Governance Workflow

Run workflow `.github/workflows/terraform-governance.yml` with operation:

- `plan`
- `apply`
- `destroy`

Execution behavior:

- `plan`: runs validation and creates plan artifact.
- `apply`: always runs plan first, then waits for `terraform-ops` environment approval, then applies saved plan artifact.
- `destroy`: always runs destroy plan first, then waits for `terraform-ops` environment approval, then applies saved destroy plan artifact.

Optional per-run overrides in workflow inputs:

- `tfvars_file` (default `dev.tfvars`)

All governance variables are sourced from the selected tfvars file.

`dev.tfvars` profile behavior:

- Creates a new governance resource group (`lekhika-dev-rg-eus2`)
- Sets policy scope to `resource_group`
- Assigns policies to that governance resource group

## 10. Validate and Troubleshoot

Validate policy assignments:

```bash
az policy assignment list \
  --scope "/subscriptions/<SUBSCRIPTION_ID>" \
  --query "[].{name:name,displayName:displayName}" -o table
```

Common login issue:

- `client-id` / `tenant-id` missing: ensure `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID` are set as repo variables or secrets.
- `AADSTS700213` with subject `environment:terraform-ops`: add matching federated credential for that GitHub environment (command above).
