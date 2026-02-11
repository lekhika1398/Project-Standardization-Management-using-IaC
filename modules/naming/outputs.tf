output "resource_name" {
  description = "Standardized resource name."
  value       = local.resource_name
}

output "segments" {
  description = "Normalized naming segments."
  value = {
    org_prefix    = local.normalized_org_prefix
    environment   = local.normalized_environment
    resource_type = local.normalized_resource_type
    region_code   = local.normalized_region_code
    instance      = local.normalized_instance
  }
}
