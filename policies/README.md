# Azure Policy Packs

This template supports unlimited custom policies through folder-based auto-discovery.

## Policy Folder Contract

Each policy folder under `policies/` must include:

- `definition.json`: Azure Policy definition using the official schema
- `policy.tf`: metadata file for package consistency

Example:

```text
policies/require-diagnostics/
├── definition.json
└── policy.tf
```

## Add a New Policy

1. Create `policies/<policy-key>/`.
2. Copy `policy.tf` from an existing policy directory.
3. Create `definition.json` with:
   - `properties.mode`
   - `properties.policyRule`
   - optional `properties.parameters`
4. If the policy has parameters, add values in `policy_assignment_parameters` in `terraform.tfvars`.
5. Run `./preflight.sh` and then deploy.

No updates are required in root Terraform files (`main.tf`, `variables.tf`, or workflow).

## Parameter Override Pattern

```hcl
policy_assignment_parameters = {
  <policy-key> = {
    <param1> = <value1>
    <param2> = <value2>
  }
}
```

## Scope Notes

- Resource group naming policies are most effective at `subscription` or `management_group` scope.
- Tagging and many resource-type controls work well at any supported scope.
