# Azure Governance Deployment Guide

## Prerequisites

- Azure subscription with Owner or User Access Administrator + Contributor permissions.
- Terraform >= 1.4.0.
- Azure CLI >= 2.50.
- GitHub repository configured for Actions.

## 1. Azure CLI Login

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
az account show --query id -o tsv
```

## 2. OIDC Service Principal Setup

```bash
SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
TENANT_ID="$(az account show --query tenantId -o tsv)"
APP_NAME="gh-terraform-governance"
GITHUB_ORG="<GITHUB_ORG>"
GITHUB_REPO="<GITHUB_REPO>"

APP_ID="$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)"
SP_OBJECT_ID="$(az ad sp create --id "$APP_ID" --query id -o tsv)"

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

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters "{\"name\":\"github-main\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_ORG}/${GITHUB_REPO}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters "{\"name\":\"github-pr\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_ORG}/${GITHUB_REPO}:pull_request\",\"audiences\":[\"api://AzureADTokenExchange\"]}"
```

Set GitHub repository variables:

- `AZURE_CLIENT_ID` = `<APP_ID>`
- `AZURE_TENANT_ID` = `<TENANT_ID>`
- `AZURE_SUBSCRIPTION_ID` = `<SUBSCRIPTION_ID>`

## 3. Backend Storage Creation

```bash
LOCATION="eastus2"
RG_NAME="rg-tfstate-prod-eus2"
SA_NAME="tfstate$RANDOM$RANDOM"
CONTAINER_NAME="tfstate"

az group create --name "$RG_NAME" --location "$LOCATION"
az storage account create \
  --name "$SA_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false

az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$SA_NAME" \
  --auth-mode login
```

Set GitHub repository variables:

- `TFSTATE_RESOURCE_GROUP` = backend resource group name
- `TFSTATE_STORAGE_ACCOUNT` = backend storage account name
- `TFSTATE_CONTAINER` = backend container name
- `TFSTATE_KEY` = `governance.terraform.tfstate`

## 4. Terraform Local Deployment

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init \
  -backend-config="resource_group_name=<TFSTATE_RESOURCE_GROUP>" \
  -backend-config="storage_account_name=<TFSTATE_STORAGE_ACCOUNT>" \
  -backend-config="container_name=<TFSTATE_CONTAINER>" \
  -backend-config="key=governance.terraform.tfstate"
terraform fmt -recursive
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

## 5. Policy Validation

Validate assignment presence:

```bash
az policy assignment list \
  --scope "/subscriptions/<SUBSCRIPTION_ID>" \
  --query "[].{name:name,displayName:displayName}" -o table
```

Validate policy effects:

```bash
az policy state list \
  --subscription "<SUBSCRIPTION_ID>" \
  --query "[].{policy:policyDefinitionName,compliance:isCompliant,resource:resourceId}" -o table
```

## 6. Failure Simulation

Attempt to create a non-compliant resource group to confirm deny effect:

```bash
az group create --name "invalid-rg-name" --location "eastus2" --tags Owner=platform-team
```

Expected result: request denied by Azure Policy for naming and missing `Environment` tag.

## 7. Destroy

```bash
terraform plan -destroy -out destroy.tfplan
terraform apply destroy.tfplan
```
