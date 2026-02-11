locals {
  normalized_org_prefix    = lower(replace(var.org_prefix, "/[^a-zA-Z0-9-]/", ""))
  normalized_environment   = lower(replace(var.environment, "/[^a-zA-Z0-9-]/", ""))
  normalized_resource_type = lower(replace(var.resource_type, "/[^a-zA-Z0-9-]/", ""))
  normalized_region_code   = lower(replace(var.region_code, "/[^a-zA-Z0-9-]/", ""))
  normalized_instance      = lower(replace(var.instance, "/[^a-zA-Z0-9-]/", ""))

  name_parts = compact([
    local.normalized_org_prefix,
    local.normalized_environment,
    local.normalized_resource_type,
    local.normalized_region_code,
    local.normalized_instance
  ])

  resource_name = join("-", local.name_parts)
}
