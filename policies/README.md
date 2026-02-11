# Azure Policy Packs

Each policy folder under `policies/` must include:

- `definition.json`: Azure Policy definition (schema-compliant JSON)
- `policy.tf`: policy package metadata file

## Add New Policies

1. Create `policies/<policy-key>/`.
2. Add `definition.json` with `properties.policyRule` and optional `properties.parameters`.
3. Add `policy.tf` by copying an existing one.
4. Optionally pass assignment parameter overrides in `policy_assignment_parameters` within `terraform.tfvars`.

The root module auto-discovers all `policies/*/definition.json` files and deploys/assigns them without modifying core Terraform files.
