# How To Use This Template

## 1. First-Time Setup

1. Configure Azure OIDC app and repository variables (`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`).
2. Run workflow `.github/workflows/backend-setup.yml` from GitHub Actions.
3. Copy backend output values to repository variables:
   - `TFSTATE_RESOURCE_GROUP`
   - `TFSTATE_STORAGE_ACCOUNT`
   - `TFSTATE_CONTAINER`
   - `TFSTATE_KEY`
4. Set required deployment variables:
   - `TF_VAR_ORG_PREFIX`
   - `TF_VAR_ENVIRONMENT`
   - `TF_VAR_REGION_CODE`
   - `TF_VAR_LOCATION`

## 2. Choose Scope

Set `policy_scope_type` using GitHub variable `TF_VAR_POLICY_SCOPE_TYPE` or `terraform.tfvars`.

- `resource_group`: assigns policies to `governance_resource_group_name`
- `subscription`: assigns policies to selected subscription
- `management_group`: assigns policies to `management_group_id`

If `management_group` is selected, `management_group_id` is required.

## 3. Configure Governance Resource Group

Create new RG:

```hcl
create_governance_resource_group = true
governance_resource_group_name   = "Lekhika_RG"
```

Reuse existing RG:

```hcl
create_governance_resource_group = false
governance_resource_group_name   = "Lekhika_RG"
```

## 4. Configure Optional Free App Service

```hcl
deploy_free_app_service = true
app_service_name_prefix = "lekhika-webapp"
```

## 5. Add Policies

1. Create folder `policies/<policy-key>/`.
2. Add `definition.json` with valid Azure Policy schema.
3. Add `policy.tf` (copy from existing policy folder).
4. Add assignment parameters (if needed) in `policy_assignment_parameters`.

No core Terraform changes are required for new policies.

## 6. Validate Before Deployment

```bash
./preflight.sh
```

## 7. Deployment Modes

Local:

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init \
  -backend-config="resource_group_name=<TFSTATE_RESOURCE_GROUP>" \
  -backend-config="storage_account_name=<TFSTATE_STORAGE_ACCOUNT>" \
  -backend-config="container_name=<TFSTATE_CONTAINER>" \
  -backend-config="key=governance.terraform.tfstate"
terraform plan -out tfplan
terraform apply tfplan
```

GitHub Actions:

- PR to `main` runs plan.
- Merge to `main` runs apply.

## 8. Change Scope Later

1. Update `TF_VAR_POLICY_SCOPE_TYPE`.
2. If needed, set `TF_VAR_MANAGEMENT_GROUP_ID`.
3. Re-run pipeline to reconcile assignments at the new scope.

## 9. Day-2 Operations

- Update policy JSON files and merge via PR.
- Add new policy folders for new controls.
- Adjust assignment parameters using `policy_assignment_parameters`.
- Periodically run `./preflight.sh` for integrity checks.
