# How To Use This Template

## 1. First-Time Setup

1. Configure OIDC values in GitHub repository (variables or secrets):
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
2. Run workflow `.github/workflows/backend-setup.yml`.
3. Copy backend output values from workflow summary into repository values:
   - `TFSTATE_RESOURCE_GROUP`
   - `TFSTATE_STORAGE_ACCOUNT`
   - `TFSTATE_CONTAINER`
   - `TFSTATE_KEY`
4. Set default Terraform values as repository variables:
   - `TF_VAR_ORG_PREFIX`
   - `TF_VAR_ENVIRONMENT`
   - `TF_VAR_REGION_CODE`
   - `TF_VAR_LOCATION`

## 2. Run Operations Manually

Run workflow `.github/workflows/terraform-governance.yml` and choose `operation`:

- `plan`: validates and shows planned changes
- `apply`: plans and applies changes (requires `terraform-apply` environment approval)
- `destroy`: plans destroy and applies destroy (requires `terraform-destroy` environment approval)

Default `tfvars_file` is `dev.tfvars`, which creates a new governance resource group and assigns policies to that resource group.

## 3. Pass Variables at Runtime

You can override defaults at run time in workflow dispatch inputs:

- `org_prefix`
- `environment`
- `region_code`
- `location`
- `tfvars_file` (for example: `dev.tfvars`)

If an input is blank, workflow uses corresponding repository variable.

## 4. Configure Policy Scope

Set default scope by repository variable `TF_VAR_POLICY_SCOPE_TYPE`:

- `resource_group`
- `subscription`
- `management_group`

If using `management_group`, also set `TF_VAR_MANAGEMENT_GROUP_ID`.

## 5. Configure Governance Resource Group

Optional default variables:

- `TF_VAR_GOVERNANCE_RG_NAME`
- `TF_VAR_CREATE_GOVERNANCE_RG`
- `TF_VAR_DEPLOY_FREE_APP_SERVICE`
- `TF_VAR_APP_SERVICE_NAME_PREFIX`

## 6. Add Policies (Unlimited)

1. Create `policies/<policy-key>/`.
2. Add `definition.json`.
3. Add `policy.tf` (copy from an existing policy folder).
4. Add assignment parameter overrides using `policy_assignment_parameters` if needed.

No root Terraform changes are required.

## 7. Validate Locally (Optional)

```bash
./preflight.sh
```

## 8. Local Terraform Commands (Optional)

```bash
terraform init \
  -backend-config="resource_group_name=<TFSTATE_RESOURCE_GROUP>" \
  -backend-config="storage_account_name=<TFSTATE_STORAGE_ACCOUNT>" \
  -backend-config="container_name=<TFSTATE_CONTAINER>" \
  -backend-config="key=governance.terraform.tfstate"
terraform plan -var-file=dev.tfvars -out tfplan
terraform apply tfplan
```
