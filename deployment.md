# Azure Governance Deployment Guide

## 1. Prerequisites

- Azure subscription and tenant access
- GitHub repository with Actions enabled
- Permissions to create Azure AD app registrations and role assignments
- Terraform backend resources will be created by workflow `backend-setup.yml`

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
  --parameters "{\"name\":\"github-pr\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_ORG}/${GITHUB_REPO}:pull_request\",\"audiences\":[\"api://AzureADTokenExchange\"]}"
```

## 3. Set Initial GitHub Repository Variables

Set these first so workflows can authenticate:

- `AZURE_CLIENT_ID` = `<APP_ID>`
- `AZURE_TENANT_ID` = `<TENANT_ID>`
- `AZURE_SUBSCRIPTION_ID` = `<SUBSCRIPTION_ID>`

## 4. Run Backend Setup Workflow

In GitHub Actions, run workflow: **Backend Setup** (`.github/workflows/backend-setup.yml`)

Inputs:

- `location` (example `eastus2`)
- `backend_resource_group` (example `rg-tfstate-prod-eus2`)
- `storage_account_prefix` (example `tfstate`)
- `container_name` (example `tfstate`)
- `state_key` (example `governance.terraform.tfstate`)

Workflow outputs values in Step Summary for:

- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT`
- `TFSTATE_CONTAINER`
- `TFSTATE_KEY`

Add these as GitHub repository variables.

## 5. Grant Backend Storage Access to Service Principal

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

## 6. Assign Governance Roles by Scope

Resource-group scope example (`Lekhika_RG`):

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

## 7. Set Required Terraform Repository Variables

- `TF_VAR_ORG_PREFIX`
- `TF_VAR_ENVIRONMENT`
- `TF_VAR_REGION_CODE`
- `TF_VAR_LOCATION`

Optional:

- `TF_VAR_POLICY_SCOPE_TYPE`
- `TF_VAR_MANAGEMENT_GROUP_ID`
- `TF_VAR_GOVERNANCE_RG_NAME`
- `TF_VAR_CREATE_GOVERNANCE_RG`
- `TF_VAR_DEPLOY_FREE_APP_SERVICE`
- `TF_VAR_APP_SERVICE_NAME_PREFIX`

## 8. Deploy via GitHub Actions

- Open PR to `main` and verify `terraform-plan` success.
- Merge PR to trigger `terraform-apply`.

## 9. Validate Deployment

Resource-group scope check:

```bash
az policy assignment list \
  --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/Lekhika_RG" \
  --query "[].{name:name,displayName:displayName}" -o table
```

Subscription scope check:

```bash
az policy assignment list \
  --scope "/subscriptions/<SUBSCRIPTION_ID>" \
  --query "[].{name:name,displayName:displayName}" -o table
```

## 10. Local Validation and Destroy (Optional)

```bash
cp terraform.tfvars.example terraform.tfvars
./preflight.sh
terraform init \
  -backend-config="resource_group_name=<TFSTATE_RESOURCE_GROUP>" \
  -backend-config="storage_account_name=<TFSTATE_STORAGE_ACCOUNT>" \
  -backend-config="container_name=<TFSTATE_CONTAINER>" \
  -backend-config="key=governance.terraform.tfstate"
terraform plan -out tfplan
terraform apply tfplan
terraform plan -destroy -out destroy.tfplan
terraform apply destroy.tfplan
```
