# How To Use This Template

## 1. First-Time Setup

1. Configure OIDC values in GitHub repository (variables or secrets):
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
   - Do not add separate `ARM_*` values.
   - Ensure Entra federated credentials include these subjects:
     - `repo:<ORG>/<REPO>:ref:refs/heads/main`
     - `repo:<ORG>/<REPO>:environment:terraform-ops`
2. Run workflow `.github/workflows/backend-setup.yml`.
3. Copy backend output values from workflow summary into repository values:
   - `TFSTATE_RESOURCE_GROUP`
   - `TFSTATE_STORAGE_ACCOUNT`
   - `TFSTATE_CONTAINER`
   - `TFSTATE_KEY`
4. Set deployment values in your selected tfvars file (for example `dev.tfvars`):
   - `org_prefix = "lekhika"`
   - `environment = "dev"`
   - `region_code = "eus2"`
   - `location = "eastus2"` (or your preferred region)

## 2. Run Operations Manually

Run workflow `.github/workflows/terraform-governance.yml` and choose `operation`:

- `plan`: validates and shows planned changes
- `apply`: runs plan first, then applies saved plan after `terraform-ops` environment approval
- `destroy`: runs destroy plan first, then applies saved destroy plan after `terraform-ops` environment approval

Default `tfvars_file` is `dev.tfvars`, which creates a new deployment resource group and assigns policies to that resource group.

## 3. Pass Variables at Runtime

You can override defaults at run time in workflow dispatch inputs:

- `tfvars_file` (for example: `dev.tfvars`)

All governance variables are read from the selected tfvars file.

## 4. Configure Policy Scope

Set `policy_scope_type` in your tfvars file:

- `resource_group`
- `subscription`
- `management_group`

If using `management_group`, also set `management_group_id` in tfvars.

## 5. Configure Deployment Resource Group

Configure these in your tfvars file:

- `deployment_resource_group_name`
- `deploy_app_service`
- `app_service_plan_sku_name` (for example: `B1`, `S1`, `F1`)
- `app_service_name_prefix`

## 6. Add Policies (Unlimited)

1. Create `policies/<policy-key>/`.
2. Add `definition.json`.
3. Add `policy.tf` (copy from an existing policy folder).
4. Add assignment parameter overrides using `policy_assignment_parameters` if needed.

No root Terraform changes are required.

## 7. Add More Resource Types

1. Create a new module under `modules/<resource-type>/`.
2. Add required variables/outputs in that module.
3. Add one module block in `main.tf` using values from tfvars.
4. Add outputs in `outputs.tf` if needed for downstream usage.
5. Run `./preflight.sh` and deploy.

## 8. Validate Locally (Optional)

```bash
./preflight.sh
```

## 9. Local Terraform Commands (Optional)

```bash
terraform init \
  -backend-config="resource_group_name=<TFSTATE_RESOURCE_GROUP>" \
  -backend-config="storage_account_name=<TFSTATE_STORAGE_ACCOUNT>" \
  -backend-config="container_name=<TFSTATE_CONTAINER>" \
  -backend-config="key=governance.terraform.tfstate"
terraform plan -var-file=dev.tfvars -out tfplan
terraform apply tfplan
```
