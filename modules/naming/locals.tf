locals {
  normalized_org_prefix    = lower(regexreplace(var.org_prefix, "[^a-zA-Z0-9-]", ""))
  normalized_environment   = lower(regexreplace(var.environment, "[^a-zA-Z0-9-]", ""))
  normalized_resource_type = lower(regexreplace(var.resource_type, "[^a-zA-Z0-9-]", ""))
  normalized_region_code   = lower(regexreplace(var.region_code, "[^a-zA-Z0-9-]", ""))
  normalized_instance      = lower(regexreplace(var.instance, "[^a-zA-Z0-9-]", ""))

  name_parts = compact([
    local.normalized_org_prefix,
    local.normalized_environment,
    local.normalized_resource_type,
    local.normalized_region_code,
    local.normalized_instance
  ])

  resource_name = join("-", local.name_parts)
}
